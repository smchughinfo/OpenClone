const setupRoutes = (app) => {
  app.use('/', require('./home'));
  app.use('/api', require('./api'));
  app.use('/auth', require('./auth'));
  app.use('/cluster', require('./cluster'));
  app.use('/webhooks', require('./webhooks'));
};

module.exports = setupRoutes;