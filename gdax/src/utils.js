// @flow
const R = require('ramda')
const _ = R.__
/* UTILS */
const toPromise = (asyncFunc: Function) =>
	new Promise((resolve, reject) => {
		const callback = (err, response, data) => err ? reject(err) : resolve(data)
		asyncFunc(callback)
	})

const numToMoney = (num: number | string): string => {
	const newNum = typeof num === 'string' ? parseFloat(num) : num
	return newNum.toFixed(2)
}

const oldpercentage = (value1: number, value2: number): number => {
	const lower = value1 < value2 ? value1 : value2
	const diff = Math.abs(value1 - value2)
	const potential = diff / lower
	return potential
}

const percentage = (askPrice: number, bidPrice: number): number =>
	(askPrice - bidPrice) / askPrice * 100

const getPhysicalCurrency = (exchangeString: string): string =>
	exchangeString.substr(4)

const end = (msg: string) => {
	console.log(msg)
	process.exit()
}

const logger = something => {
	console.log(something)
	return something
}

const stringify = json => R.pipe(
	JSON.stringify(_, null, ' '),
	console.log,
)(json)

module.exports = {
	toPromise,
	stringify,
	numToMoney,
	percentage,
	end,
	getPhysicalCurrency,
	logger,
}
