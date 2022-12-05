var passport = require('passport');
var LocalStrategy = require('passport-local');
const userService = require('../services/userService');
const driverService = require('../services/driverService');
const bcrypt = require('bcrypt');

passport.use(
    new LocalStrategy(
        async function verify(username, password, cb) {
            try{
                //get user account
                const userAccount = await userService.getAccount(username);

                //check username
                if(!userAccount){
                    console.log('Incorrect username!');
                    return cb(null, false, { message: 'Incorrect username!' });
                }

                //check password
                const match = await bcrypt.compare(password, userAccount.MatKhau);
                if(!match){
                    console.log('Incorrect password!')
                    return cb(null, false, { message: 'Incorrect password!' });

                }

                //veryfi successfully
                let userInfo = await userService.getInfoByUserName(username);

                if(!userInfo){
                    userInfo = await driverService.getInfoByUserName(username);
                }

                return cb(null, userInfo);

            }
            catch(error){
                console.log(error);
                cb(err);
            }
        }
    )
);

passport.serializeUser(function(userInfo, cb) {
    process.nextTick(function() {
      cb(null, { KhachHangID: userInfo.KhachHangID || userInfo.TaiXeID, Username: userInfo.Username });
    });
});
  
passport.deserializeUser(function(userInfo, cb) {
    process.nextTick(function() {
      return cb(null, userInfo);
    });
});

module.exports = passport;