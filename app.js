// Azure Migration Service

var express = require('express');
var http = require('http');
var path = require('path');
var session = require('express-session');
//var param = require('express-parameters');
var bodyParser = require('body-parser');
var async = require('async');    
var flatfile = require('flat-file-db');
var app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser('S3CRE7'));
  app.use(express.cookieSession());
  app.use(bodyParser.json()); // support json encoded bodies
  app.use(bodyParser.urlencoded({ extended: true }));
  app.use(session({secret: 'The Coretek Cloud Practice Rocks', cookie: { maxAge: 60000 * 30 }}));
  app.use(express.static(path.join(__dirname, 'public')));
  app.use(app.router);
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

var DB = flatfile.sync("app.db");

// Welcome Page
app.get('/', function (req, res) {

    if (req.session.name) { res.redirect('/dashboard/' + req.session.name); }
    res.render('welcome', { title: 'Welcome to the Azure Migration Service', name: undefined })
})

app.get('/welcome', function (req, res) { res.redirect('/');});

// Activation Page
app.get('/activation/:name', function (req, res) 
{
  if (req.params.name) 
  {
    res.render('activation', { title: 'AMS Account Activation', name: req.params.name })
  }
  res.redirect('/')
});

// Dashboard Page
app.get('/dashboard', function (req, res)
{
  if (req.session === null) { res.redirect('/') }
  if (req.session.name) { res.redirect('/dashboard/' + req.session.name) }
});

app.get('/dashboard/:name', function (req, res)
{
  if ( req.session === null || req.session.name !== req.params.name ) { res.redirect('/signout') }
  res.render('dashboard', { title: 'AMS Dashboard', name: req.params.name })
})

// Profile Page
app.get('/profile', function (req, res)
{
  if (req.session === null) { res.redirect('/') }
  if (req.session.name) { res.redirect('/profile/' + req.session.name) }
})

app.get('/profile/:name', function(req, res) 
{
  if (req.params.name && req.session.name) 
  {
    if (req.params.name === req.session.name) 
    {
      DB.keys().forEach(function(id)
      {
        var account = DB.get(id)

        if(account.name === req.session.name)
        {
          res.render('profile', { title: 'AMS Profile of ' + req.params.name + '', name: req.params.name, account: account })
        }
      })
    }
  }
  else 
  {
    res.redirect('/welcome')
  }
})

// Sign Out
app.get('/signout', function (req, res) 
{
  req.session = null;
  res.redirect('/')
})

/* Form Handlers */

// Sign In
app.post('/signin', function (req, res)
{
  if (req.body.name && req.body.password)
  {
    DB.keys().forEach(function(id)
    {
      var account = DB.get(id)

      if(account.name === req.body.name)
      {
        if(account.password === req.body.password)
        {
          if(account.activated)
          {
            req.session.name = account.name;
            res.redirect('/dashboard/' + req.session.name)
          }
          else 
          {
            res.redirect('/activation/' + account.name)
          }
        }
      }
      res.redirect('/')
    })
  }
  else 
  {
    res.redirect('/')
  }
  //res.redirect('/')
})

// Sign Up
app.post('/signup', function (req, res) {

    if (req.body.name && req.body.email && req.body.phone && req.body.password) 
    {
      var id = DB.keys().length + 1

      DB.put(id, {
        name: req.body.name, 
        email: req.body.email,
        phone: req.body.phone,
        password: req.body.password,
        azure_asm_login: null,
        azure_asm_password: null,
        azure_arm_login: null,
        azure_arm_password: null,
        activated: false
      })    
      res.redirect('/activation/' + req.body.name) 
    }
    else 
    {
      res.redirect('/')
    }
})

// Profile Form 
app.post('/profile/:name/update', function(req, res)
{
  if (req.session.name && req.params.name)
  {
    if (req.body.name && req.body.email && req.body.phone && req.body.password) 
    {
      DB.keys().forEach(function(id)
      {
        var account = DB.get(id)

        if (account.name === req.params.name) 
        {
          DB.del(id)

          DB.put(id, {
            name: req.body.name, 
            email: req.body.email,
            phone: req.body.phone,
            password: req.body.password,
            azure_asm_login: req.body.azure_asm_login,
            azure_asm_password: req.body.azure_asm_password,
            azure_arm_login: req.body.azure_arm_login,
            azure_arm_password: req.body.azure_arm_password,
            activated: true
          })
          
          DB.close()

          req.session.name = req.body.name
          res.redirect('/profile/' + req.session.name)    
        }
      })
      DB.close()
    }
  }
  else
  {
    res.redirect('/')
  }
})

/*
  C o r e t e k   C l o u d   C o n t r o l 
*/

/* Microsoft Azure Services */

// Azure Login 
app.get('/azure/login/:azure_username/:azure_password', function (req, res)
{

    if (req.params.azure_username && req.params.azure_password)
    {
        var command = require('child_process').exec;

        var azure = 'azure login -u ' + req.params.azure_username + ' -p ' + req.params.azure_password + ' --json';

        command(azure, function (error, stdout, stderr)
        {
          res.json(stdout)
        })
    }
});

// Azure Logout 
app.get('/azure/logout/:azure_username', function (req, res)
{

    if (req.params.azure_username)
    {
        var command = require('child_process').exec;

        var azure = 'azure logout -u ' + req.params.azure_username + ' --json';

        command(azure, function (error, stdout, stderr)
        {
          res.json(stdout)
        })
    }
});

/* Azure Service Manager */

// Azure ASM Account List
app.get('/azure/asm/account/list', function (req, res)
{
    var command = require('child_process').exec;

    command("azure config mode asm", function (error, stdout, stderr)
    {
        console.log(stdout);
    });

    var azure = 'powershell.exe -WindowStyle Hidden -NoLogo -Command "azure account list --json"';
  
    command(azure, function (error, stdout, stderr)
    {
      res.json(stdout)
    })
});

// Azure ASM Account Set
app.put('/azure/asm/account/set/:tenantId', function (req, res)
{
    var command = require('child_process').exec;

    command("azure config mode asm", function (error, stdout, stderr)
    {
        console.log(stdout)
    });

    var azure = 'powershell.exe -WindowStyle Hidden -NoLogo -Command "azure account set ' + req.params.tenantId + ' --json"';
  
    command(azure, function (error, stdout, stderr)
    {
        res.json(stdout)
    })
});

// Azure ASM Service List
app.get('/azure/asm/service/list', function (req, res, next)
{
  var command = require('child_process').exec;

  command("azure config mode asm", function (error, stdout, stderr)
  {
      console.log(stdout);
  });
  
  var azure = 'powershell.exe -WindowStyle Hidden -NoLogo -Command "azure service list --json"';

  command(azure, function (error, stdout, stderr)
  {
    res.json(stdout)
  });
});

// Azure ASM Service Show
app.get('/azure/asm/service/show/:serviceName', function (req, res)
{
    var command = require('child_process').exec;

    command("azure config mode asm", function (error, stdout, stderr)
    {
        console.log(stdout);
    });
    
    var azure = 'powershell.exe -WindowStyle Hidden -NoLogo -Command "azure service show --serviceName ' + req.params.serviceName + ' --json"';

    command(azure, function (error, stdout, stderr)
    {
      res.json(stdout)
    })
});

/* Azure Resource Manager */

// Azure ARM Account List
app.get('/azure/arm/account/list', function (req, res)
{
    var command = require('child_process').exec;

    command("azure config mode arm", function (error, stdout, stderr)
    {
        console.log(stdout);
    })

    var azure = 'powershell.exe -WindowStyle Hidden -NoLogo -Command "azure account list --json"';
  
    command(azure, function (error, stdout, stderr)
    {
        res.json(stdout)
    })
})


// Azure ARM Account Set
app.put('/azure/arm/account/set/:tenantId', function (req, res)
{
    var command = require('child_process').exec;

    command("azure config mode arm", function (error, stdout, stderr)
    {
        console.log(stdout);
    })

    var azure = 'powershell.exe -WindowStyle Hidden -NoLogo -Command "azure account set ' + req.params.tenantId + ' --json"';
  
    command(azure, function (error, stdout, stderr)
    {
        res.json(stdout)
    })
})

// Azure ARM Group List
app.get('/azure/arm/group/list', function (req, res)
{
    var command = require('child_process').exec;

    command("azure config mode arm", function (error, stdout, stderr)
    {
        console.log(stdout);
    })
    
    var azure = 'powershell.exe -WindowStyle Hidden -NoLogo -Command "azure group list --json"';

    command(azure, function (error, stdout, stderr)
    {
      res.json(stdout)
    })
})

// Azure ARM Resource List
app.get('/azure/arm/resource/list/:name', function (req, res)
{
    var command = require('child_process').exec;

    command("azure config mode arm", function (error, stdout, stderr)
    {
        console.log(stdout);
    })
    
    var azure = 'powershell.exe -WindowStyle Hidden -NoLogo -Command "azure resource list ' + req.params.name + ' --json"';

    command(azure, function (error, stdout, stderr)
    {
      res.json(stdout)
    })
})

/* Amazon Web Services */

/*
    Under design for a future milestone
*/

// AMS Server Properties
http.createServer(app).listen(app.get('port'), function(){
  console.log("Coretek AMS Server Listening @ Port: " + app.get('port'));
});
