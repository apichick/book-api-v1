/*jshint esversion: 6 */
const _ = require('lodash');
const apickli = require('apickli');
const {
    Before,
    setDefaultTimeout
} = require('cucumber');

setDefaultTimeout(20 * 1000);

Before(function () {
    this.apickli = new apickli.Apickli(this.parameters.scheme, this.parameters.domain);
    _.extend(this.apickli.scenarioVariables, this.parameters)
});