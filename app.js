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
    
    res.render('welcome', { title: 'Welcome to the Azure Migration Service', name: undefined });

});

app.get('/welcome', function (req, res) { res.redirect('/');});

// Sign In Form Handler
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
            res.redirect('/dashboard/' + req.session.name);
          }
          else 
          {
            res.redirect('/activation/' + account.name);
          }
        }
      }
    })
  }
  res.redirect('/');
});

// Sign Up Form
app.post('/signup', function (req, res) {

    if (req.body.name && req.body.email && req.body.phone && req.body.password) 
    {
      var id = DB.keys().length + 1;

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
      });
      
      res.redirect('/activation/' + req.body.name);   
    }
});

// Activation Page
app.get('/activation/:name', function (req, res) 
{
  if (req.params.name) 
  {
    res.render('activation', { title: 'AMS Account Activation', name: req.params.name })
  }
  res.redirect('/')
});

// Sign Out Form Handler
app.get('/signout', function (req, res) 
{
  req.session = null;
  res.redirect('/');
});

// Dashboard Page
app.get('/dashboard', function (req, res)
{
  if (req.session === null) { res.redirect('/') }
  if (req.session.name) { res.redirect('/dashboard/' + req.session.name) }
});

app.get('/dashboard/:name', function (req, res)
{
  if ( req.session === null || req.session.name != req.params.name ) { res.redirect('/signout') }
  res.render('dashboard', { title: 'AMS Dashboard', name: req.params.name })
});

/*
  C o r e t e k   C l o u d   S e r v i c e s 
*/

// Azure ASM Login 
app.post('/azure/asm/login/:name', function (req, res)
{

    if (req.body.azure_username && req.body.azure_password)
    {
        var command = require('child_process').exec;

        var azure = 'azure login -u ' + req.body.azure_username + ' -p ' + req.body.azure_password + ' --json';

        command(azure, function (error, stdout, stderr)
        {
            res.json(JSON.parse(error));
        });

        //res.json(JSON.parse(azure.stdout.pipe(process.stdout)));
        //res.redirect('/dashboard/' + req.params.name);
    }
});

/* 
  Azure Service Manager Services 
*/

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
        res.json(stdout);
    });
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

/* 
  Azure Resource Manager Services 
*/

// Azure ARM Account List
app.get('/azure/arm/account/list', function (req, res, next)
{
    var command = require('child_process').exec;

    setTimeout(function(){
        command("azure config mode arm", function (error, stdout, stderr)
        {
            console.log(stdout);
        });
    }, 3000);

    var azure = 'powershell.exe -WindowStyle Hidden -NoLogo -Command "azure account list --json"';

    command(azure, function (error, stdout, stderr)
    {
        setTimeout(function(){
            res.json(stdout);
        }, 3000);
    });

    next();
});

// Azure ARM Group List
app.get('/azure/arm/group/list', function (req, res, next)
{
 
    var command = require('child_process').exec;

    command("azure config mode arm", function (error, stdout, stderr)
    {
        console.log(stdout);
    });
    
    var azure = 'powershell.exe -WindowStyle Hidden -NoLogo -Command "azure group list --json"';

    command(azure, function (error, stdout, stderr)
    {
      res.json(stdout)
    });
});

http.createServer(app).listen(app.get('port'), function(){
  console.log("Coretek AMS Server Listening @ Port: " + app.get('port'));
});
