const { issueRefund } = require('../services/refundService');

class StripeWebhookHandlers {
  static handleCheckoutSessionCompleted(session, webhookType) {
    console.log('💰 Payment succeeded for session:', session.id);
    
    if (webhookType === 'snapshot') {
      console.log('Customer email:', session.customer_details?.email);
      console.log('Amount paid:', session.amount_total / 100, session.currency);
      
      // Issue immediate refund for testing
      if (session.payment_intent) {
        const paymentData = {
          sessionId: session.id,
          email: session.customer_details?.email,
          amount: session.amount_total / 100,
          currency: session.currency
        };
        
        issueRefund(session.payment_intent, paymentData);
      }
    }
  }

  static handleWebhookEvent(event, webhookType = 'legacy') {
    console.log(`📥 Received ${webhookType} webhook:`, event.type);

    if(event.type == 'checkout.session.completed') {
      this.handleCheckoutSessionCompleted(event.data.object, webhookType);
    }
  }
}

module.exports = StripeWebhookHandlers;