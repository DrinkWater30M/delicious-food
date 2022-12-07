function verifyLogin(req, res, next){
    if(!req.user){
        res.redirect('/user/login');
        return;
    }

    return next(); 
}

function assignUser(req, res, next){
    if(req.user){
        res.locals.user = {...req.user};
    }
    
    next();
}

function verifyDriverLogin(req, res, next){
    if(!req.user){
        res.redirect('/driver/login');
        return;
    }

    return next(); 
}

module.exports = {
    verifyLogin,
    assignUser,
    verifyDriverLogin,
}