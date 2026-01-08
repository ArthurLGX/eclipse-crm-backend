'use strict';

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::time-entry.time-entry');

