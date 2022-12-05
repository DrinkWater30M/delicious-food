async function logout(req, res, next) {
    await req.logout((err) => {
        if (err) { return next(err); }
        res.redirect('/');
    });
}

async function driverLogout(req, res, next) {
    await req.logout((err) => {
        if (err) { return next(err); }
        res.redirect('/driver/home');
    });
}

module.exports = {
    logout,
    driverLogout,
}