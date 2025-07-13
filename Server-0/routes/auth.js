const express = require('express');
const passport = require('passport');
const router = express.Router();

// Google OAuth routes
router.get('/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

router.get('/signin-google',
  passport.authenticate('google', { failureRedirect: '/' }),
  (req, res) => {
    // Redirect to user info page to see authentication worked
    res.redirect('/auth/user-info');
  }
);

router.get('/logout', (req, res) => {
  req.logout(() => {
    res.redirect('/');
  });
});

// User info endpoint (JSON)
router.get('/user', (req, res) => {
  if (req.isAuthenticated()) {
    res.json({
      isLoggedIn: true,
      email: req.user.emails[0].value,
      name: req.user.displayName
    });
  } else {
    res.json({ isLoggedIn: false });
  }
});

// User info page (HTML) - for debugging OAuth
router.get('/user-info', (req, res) => {
  if (req.isAuthenticated()) {
    const user = req.user;
    const html = `
<!DOCTYPE html>
<html>
<head>
    <title>Authentication Success - CloneZone</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container { 
            background: rgba(255,255,255,0.1); 
            padding: 30px; 
            border-radius: 15px; 
            max-width: 600px; 
            margin: 0 auto;
            backdrop-filter: blur(10px);
        }
        .success { color: #4CAF50; font-size: 1.2em; margin-bottom: 20px; }
        .user-data { 
            background: rgba(255,255,255,0.1); 
            padding: 20px; 
            border-radius: 10px; 
            margin: 20px 0; 
        }
        .field { margin: 10px 0; }
        .label { font-weight: bold; }
        .value { margin-left: 10px; color: #f0f0f0; }
        .actions { margin-top: 30px; }
        .btn { 
            background: #4CAF50; 
            color: white; 
            padding: 10px 20px; 
            text-decoration: none; 
            border-radius: 5px; 
            margin-right: 10px;
            display: inline-block;
        }
        .btn:hover { background: #45a049; }
        .raw-data { 
            background: rgba(0,0,0,0.3); 
            padding: 15px; 
            border-radius: 5px; 
            margin-top: 20px;
            font-family: monospace;
            font-size: 0.9em;
            white-space: pre-wrap;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Authentication Successful!</h1>
        <div class="success">✅ Google OAuth login completed successfully</div>
        
        <div class="user-data">
            <h3>User Information:</h3>
            <div class="field">
                <span class="label">Name:</span>
                <span class="value">${user.displayName || 'Not provided'}</span>
            </div>
            <div class="field">
                <span class="label">Email:</span>
                <span class="value">${user.emails?.[0]?.value || 'Not provided'}</span>
            </div>
            <div class="field">
                <span class="label">Google ID:</span>
                <span class="value">${user.id || 'Not provided'}</span>
            </div>
            <div class="field">
                <span class="label">Profile Picture:</span>
                <span class="value">${user.photos?.[0]?.value ? `<img src="${user.photos[0].value}" style="width: 50px; height: 50px; border-radius: 25px; vertical-align: middle;">` : 'Not provided'}</span>
            </div>
        </div>
        
        <div class="actions">
            <a href="/" class="btn">← Back to Home</a>
            <a href="/auth/logout" class="btn" style="background: #f44336;">Logout</a>
        </div>
        
        <details>
            <summary style="cursor: pointer; margin-top: 20px;">🔍 View Raw User Data</summary>
            <div class="raw-data">${JSON.stringify(user, null, 2)}</div>
        </details>
    </div>
</body>
</html>`;
    res.send(html);
  } else {
    res.redirect('/auth/google');
  }
});

module.exports = router;