const express = require('express');
const router = express.Router();

// Stripe webhook endpoint
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