const {
  pipe,
  pipeP,
  map,
  __,
  chain,
  prop,
  inc,
  slice,
  indexOf,
  reject,
  join,
  reduce,
  flatten,
  equals,
  replace,
  max,
  concat,
  flip,
  compose,
  curry,
  merge,
  objOf,
} = require('ramda')
const {
  toPromise,
  stringify,
  numToMoney,
  percentage,
  end,
  getPhysicalCurrency,
  logger,
} = require('./utils')

const Gdax = require('gdax')
const yql = require('yql-node')
  .formatAsJSON()
  .setQueryParameter(objOf('env', 'store://datatables.org/alltableswithkeys'))

const EXCHANGES = [
  'BTC-USD',
  'BTC-EUR',
  'BTC-GBP',
]
const QUERY_TEMPLATE = 'select * from yahoo.finance.xchange where pair in ("EXCHANGE_PLACEHOLDER")'
const POLL_RATE_SEC = 3 // 1 per 1.8 s = 2000 hit per hour limit to yql
const POLL_RATE = POLL_RATE_SEC * 1000 // DONT CHANGE
const PERCENT_FEE = 0.0 // 0.25 % per exchange
const SHOULD_CLEAR_SCREEN = true
const SHOULD_SHOW_DIAGNOSTICS = true

let ticker_count = 0
let error_count = 0
let request_count = 0
/* FUNCTION CALLED EVERY POLL_RATE MS */
const poll = (initialContexts, query) =>
  fetchAllData(initialContexts, query)
  .catch(handleError)
  .then(curry(fillOutContexts)(initialContexts))
  .then(getPrices)
  .then(getGaps)
  .then(display)


const handleError = error => {
  if(error instanceof Error){
    error_count++
    console.log(error.message)

  } else {
    console.log("'this ain't no error!");
  }
}

const initClients = map(exchange => ({
  exchange,
  publicClient: new Gdax.PublicClient(exchange),
}))(EXCHANGES)

const main = () => {
  const contextualPoll = poll.bind(null, initClients, initializeQuery)
  setInterval(contextualPoll, POLL_RATE)
}

function fetchAllData(initContexts, query) {
  request_count++
  const fetchExchangeRates = query =>
    new Promise((resolve, reject) => {
      const callback = (error, response) => error ? reject(error) : resolve(response)
      yql.execute(query, callback)
    })
  const fetchOrderBooks = contexts =>
    Promise.all(
      map(context => toPromise(c => context.publicClient.getProductOrderBook(c)), contexts)
    )

  const requests = Promise.all([
    fetchExchangeRates(query),
    fetchOrderBooks(initContexts),
  ])
  return requests
}

function fillOutContexts(initContexts, responses) {
  const addRatesToContext = curry((yqlResponse, contexts) => {
    const rates = yqlResponse.query.results.rate
    // yqlResponse.query ? ()=>{} : console.log(yqlResponse)
    const dict = {
      USD: 1,
      EUR: rates[0].Rate,
      GBP: rates[1].Rate,
    }
    const addXRate = context =>
      pipe(
        prop('exchange'),
        getPhysicalCurrency,
        prop(__, dict),
        objOf('xrate'),
        merge(context),
      )(context)
    return map(addXRate, contexts)
  })

  const addBooksToContext = curry((books, contexts) =>
    contexts.map((context, index) => ({
      ...context,
      book: books[index],
    }))
  )
  const yqlResponse = responses[0]
  const gdaxResponse = responses[1]
  return pipe(
    addRatesToContext(yqlResponse),
    addBooksToContext(gdaxResponse),
  )(initContexts)
}

const getPrices = map(context => {
  const xrate = context.xrate
  const book = context.book
  return {
    exchange: context.exchange,
    bid: book.bids[0][0] * xrate,
    ask: book.asks[0][0] * xrate,
  }
})

const getGaps = prices =>
  chain(context => {
    const exchange = context.exchange
    return pipe(
      indexOf(__, prices),
      inc,
      slice(__, Infinity, prices),
      map(altContext => {
        const oneToTwo = percentage(context.ask, altContext.bid)
        const TwoToOne = percentage(altContext.ask, context.bid)
        const maxGap = max(oneToTwo, TwoToOne)
        const arrow = maxGap === oneToTwo ? ' -> ' : ' <- '
        const str = getPhysicalCurrency(exchange) + arrow + exchange.substring(0, 3) + arrow + getPhysicalCurrency(altContext.exchange)
        return {
          percent: maxGap,
          str,
        }
      }),
    )(context)
  }, prices)

const initializeQuery = pipe(
  map(getPhysicalCurrency),
  reject(equals('USD')),
  map(concat(__, 'USD')),
  join(', '),
  replace(/EXCHANGE_PLACEHOLDER/, __, QUERY_TEMPLATE),
)(EXCHANGES)

function display(gaps) {
  const clearScreen = SHOULD_CLEAR_SCREEN ? '\x1Bc\n' : ''
  const label = 'GAPS::\t'
  const ticker = '.'.repeat(ticker_count)
  ticker_count = ++ticker_count % 4
  const gapStrings = map(gap => gap.str + ': ' + numToMoney(gap.percent - PERCENT_FEE) + ' %\t', gaps)

  const errorDisplay = SHOULD_SHOW_DIAGNOSTICS ?
    '\nRequest Count: ' + request_count +
    '\nError Count: ' + error_count +
    '\nError Rate: ' + (error_count / request_count * 100) + '%' :
    ''
  const ui = [
    clearScreen,
    label,
    gapStrings,
    ticker,
    errorDisplay,
  ]

  pipe(
    flatten,
    reduce(concat, ''),
    console.log,
  )(ui)
}

main()
