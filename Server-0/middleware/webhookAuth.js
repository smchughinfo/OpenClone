/**
 * Stripe Webhook Authentication Middleware
 * 
 * Handles Stripe webhook signature verification for security.
 */

/**
 * Create webhook authentication middleware for specific webhook types
 * @param {string} webhookType - Type of webhook (snapshot/thin/legacy)
 * @returns {Function} Express middleware function
 */
function createWebhookAuthMiddleware(webhookType) {
  return (req, res, next) => {
    const sig = req.headers['stripe-signature'];
    
    // Get the appropriate webhook secret based on type
    let secretKey;
    switch (webhookType) {
      case 'snapshot':
        secretKey = process.env.STRIPE_WEBHOOK_SECRET_SNAPSHOT;
        break;
      case 'thin':
        secretKey = process.env.STRIPE_WEBHOOK_SECRET_THIN;
        break;
      case 'legacy':
      default:
        secretKey = process.env.STRIPE_WEBHOOK_SECRET;
        break;
    }
    
    if (!secretKey) {
      const envVarName = webhookType === 'legacy' 
        ? 'STRIPE_WEBHOOK_SECRET' 
        : `STRIPE_WEBHOOK_SECRET_${webhookType.toUpperCase()}`;
      
      console.log(`${envVarName} not configured`);
      return res.status(400).send(`Webhook secret for ${webhookType} not configured`);
    }

    let event;
    try {
      const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
      event = stripe.webhooks.constructEvent(req.body, sig, secretKey);
      console.log(`✅ ${webhookType} webhook signature verified`);
      
      // Attach verified event to request for handlers
      req.stripeEvent = event;
      next();
    } catch (err) {
      console.log(`❌ ${webhookType} webhook signature verification failed:`, err.message);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }
  };
}

module.exports = {
  createWebhookAuthMiddleware
};