const { Sequelize } = require('sequelize');

//create instance db
const sequelize = new Sequelize(
    process.env.DB_NAME, 
    process.env.DB_USERNAME, 
    process.env.DB_PASSWORD, 
    {
        host: process.env.DB_HOST,
        dialect: process.env.DB_TYPE,
        dialectOptions: {
            options: {
              requestTimeout: 100000
            }
        },
    }
);

module.exports = sequelize;