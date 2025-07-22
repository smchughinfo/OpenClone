const express = require('express');
const router = express.Router();

const StripeWebhookHandlers = require('../handlers/stripeWebhookHandlers');
const { createWebhookAuthMiddleware } = require('../middleware/webhookAuth');

// Webhook handler that processes verified Stripe events
const handleVerifiedWebhook = (webhookType) => {
  return (req, res) => {
    // Event was already verified by middleware, now handle it
    StripeWebhookHandlers.handleWebhookEvent(req.stripeEvent, webhookType);
    
    // Return success response to Stripe
    res.json({received: true});
  };
};

// Snapshot webhook (full data) - primary endpoint for cluster provisioning
router.post('/stripe-snapshot', 
  express.raw({type: 'application/json'}), 
  createWebhookAuthMiddleware('snapshot'),
  handleVerifiedWebhook('snapshot')
);

// Thin webhook (minimal data) - for analytics/monitoring
router.post('/stripe-thin', 
  express.raw({type: 'application/json'}), 
  createWebhookAuthMiddleware('thin'),
  handleVerifiedWebhook('thin')
);

// Legacy endpoint (keeping for backwards compatibility)
router.post('/stripe', 
  express.raw({type: 'application/json'}), 
  createWebhookAuthMiddleware('legacy'),
  handleVerifiedWebhook('legacy')
);

module.exports = router;