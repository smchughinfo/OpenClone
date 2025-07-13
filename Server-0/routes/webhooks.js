const express = require('express');
const router = express.Router();

// Auto-refund system - tracks payments and monitors cluster deployment
const activePayments = new Map(); // paymentIntentId -> { sessionId, email, amount, startTime, chargeId }

const checkClusterStatus = async (paymentIntentId) => {
  try {
    const response = await fetch('https://app.clonezone.me', { 
      method: 'HEAD',
      timeout: 5000 
    });
    
    if (response.ok) {
      console.log('🎯 Cluster is LIVE! No refund needed for payment:', paymentIntentId);
      activePayments.delete(paymentIntentId);
      return true;
    }
  } catch (error) {
    console.log('⏳ Cluster not ready yet for payment:', paymentIntentId);
  }
  return false;
};

const issueRefund = async (paymentIntentId, reason = 'Cluster failed to provision within 1 hour') => {
  const paymentData = activePayments.get(paymentIntentId);
  
  if (!paymentData) {
    console.log('⚠️ No payment data found for refund:', paymentIntentId);
    return;
  }
  
  try {
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
    
    // Use charge ID if we have it, otherwise try to get it from payment intent
    let refundTarget = {};
    if (paymentData.chargeId) {
      console.log('💳 Refunding charge:', paymentData.chargeId);
      refundTarget.charge = paymentData.chargeId;
    } else {
      console.log('🔍 No charge ID stored, fetching from payment intent:', paymentIntentId);
      // Get the payment intent to find the charge
      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
      if (paymentIntent.charges && paymentIntent.charges.data.length > 0) {
        const chargeId = paymentIntent.charges.data[0].id;
        console.log('💳 Found charge ID:', chargeId);
        refundTarget.charge = chargeId;
      } else {
        throw new Error('No charge found for payment intent');
      }
    }
    
    const refund = await stripe.refunds.create({
      ...refundTarget,
      reason: 'requested_by_customer'
    });
    
    console.log('💸 AUTO-REFUND ISSUED:', {
      paymentIntentId,
      chargeId: refundTarget.charge,
      refundId: refund.id,
      amount: paymentData.amount,
      email: paymentData.email,
      reason
    });
    
    // Clean up successful refund
    activePayments.delete(paymentIntentId);
  } catch (error) {
    console.error('❌ Refund failed:', error.message);
    // Note: NOT cleaning up failed refund - this might be the source of infinite retries
  }
};

const startRefundTimer = (paymentIntentId) => {
  const TIMEOUT_MS = 60 * 60 * 1000; // 1 hour
  const CHECK_INTERVAL_MS = 30 * 1000; // Check every 30 seconds
  
  console.log(`⏰ Starting 1-hour refund timer for payment: ${paymentIntentId}`);
  
  const intervalId = setInterval(async () => {
    const isClusterLive = await checkClusterStatus(paymentIntentId);
    if (isClusterLive) {
      clearInterval(intervalId);
      return;
    }
    
    const paymentData = activePayments.get(paymentIntentId);
    if (!paymentData) {
      clearInterval(intervalId);
      return;
    }
    
    const elapsedTime = Date.now() - paymentData.startTime;
    if (elapsedTime >= TIMEOUT_MS) {
      clearInterval(intervalId);
      await issueRefund(paymentIntentId, 'Cluster failed to provision within 1 hour');
    }
  }, CHECK_INTERVAL_MS);
};

// Stripe webhook endpoints
const handleStripeWebhook = (webhookType) => {
  return (req, res) => {
    const sig = req.headers['stripe-signature'];
    
    // Get the appropriate webhook secret based on type
    const secretKey = webhookType === 'snapshot' 
      ? process.env.STRIPE_WEBHOOK_SECRET_SNAPSHOT 
      : process.env.STRIPE_WEBHOOK_SECRET_THIN;
    
    if (!secretKey) {
      console.log(`STRIPE_WEBHOOK_SECRET_${webhookType.toUpperCase()} not configured`);
      return res.status(400).send(`Webhook secret for ${webhookType} not configured`);
    }

    let event;
    try {
      const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
      event = stripe.webhooks.constructEvent(req.body, sig, secretKey);
      console.log(`✅ ${webhookType} webhook signature verified`);
    } catch (err) {
      console.log(`❌ ${webhookType} webhook signature verification failed:`, err.message);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Handle the event
    console.log(`📥 Received ${webhookType} webhook:`, event.type);
    
    switch (event.type) {
      case 'checkout.session.completed':
        const session = event.data.object;
        console.log('💰 Payment succeeded for session:', session.id);
        if (webhookType === 'snapshot') {
          console.log('Customer email:', session.customer_details?.email);
          console.log('Amount paid:', session.amount_total / 100, session.currency);
          
          // Store payment data for potential refund
          if (session.payment_intent) {
            activePayments.set(session.payment_intent, {
              sessionId: session.id,
              email: session.customer_details?.email,
              amount: session.amount_total / 100,
              currency: session.currency,
              startTime: Date.now()
            });
            
            // Start auto-refund timer that checks for app.clonezone.me
            startRefundTimer(session.payment_intent);
            console.log('⏰ Auto-refund protection started - cluster has 1 hour to come online');
          }
        }
        
        // TODO: Start cluster provisioning
        console.log('🚀 TODO: Trigger cluster provisioning for customer');
        break;
        
      case 'payment_intent.succeeded':
        const paymentIntent = event.data.object;
        console.log('💳 Payment intent succeeded:', paymentIntent.id);
        // Just log - checkout.session.completed will handle provisioning and refund timer
        break;
        
      case 'charge.succeeded':
        const charge = event.data.object;
        console.log('💳 Charge succeeded:', charge.id, 'for payment intent:', charge.payment_intent);
        
        // Store charge ID for potential refund
        if (charge.payment_intent && activePayments.has(charge.payment_intent)) {
          const paymentData = activePayments.get(charge.payment_intent);
          paymentData.chargeId = charge.id;
          activePayments.set(charge.payment_intent, paymentData);
          console.log('💾 Stored charge ID for refund purposes');
        }
        break;
        
      default:
        console.log(`❓ Unhandled event type: ${event.type}`);
    }

    // Return a 200 response to acknowledge receipt of the event
    res.json({received: true});
  };
};

// Snapshot webhook (full data) - primary endpoint for cluster provisioning
router.post('/stripe-snapshot', express.raw({type: 'application/json'}), handleStripeWebhook('snapshot'));

// Thin webhook (minimal data) - for analytics/monitoring
router.post('/stripe-thin', express.raw({type: 'application/json'}), handleStripeWebhook('thin'));

// Legacy endpoint (keeping for backwards compatibility)
router.post('/stripe', express.raw({type: 'application/json'}), (req, res) => {
  const sig = req.headers['stripe-signature'];
  
  if (!process.env.STRIPE_WEBHOOK_SECRET) {
    console.log('STRIPE_WEBHOOK_SECRET not configured');
    return res.status(400).send('Webhook secret not configured');
  }

  let event;
  try {
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
    event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
    console.log('✅ Webhook signature verified');
  } catch (err) {
    console.log('❌ Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  console.log('📥 Received webhook:', event.type);
  
  switch (event.type) {
    case 'checkout.session.completed':
      const session = event.data.object;
      console.log('💰 Payment succeeded for session:', session.id);
      console.log('Customer email:', session.customer_details?.email);
      console.log('Amount paid:', session.amount_total / 100, session.currency);
      
      // TODO: Start cluster provisioning
      console.log('🚀 TODO: Trigger cluster provisioning for customer');
      break;
      
    case 'payment_intent.succeeded':
      const paymentIntent = event.data.object;
      console.log('💳 Payment intent succeeded:', paymentIntent.id);
      break;
      
    default:
      console.log(`❓ Unhandled event type: ${event.type}`);
  }

  // Return a 200 response to acknowledge receipt of the event
  res.json({received: true});
});

module.exports = router;