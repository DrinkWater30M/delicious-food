const userService = require('../services/userService');

async function getHomePage(req, res){
    try{
        if(req.user){
            res.locals.user = {...req.user};
            console.log(req.user);
        }
        
        res.render('home.hbs');
    }
    catch(error){
        console.log(error);
    }
}

module.exports = {
    getHomePage,
}