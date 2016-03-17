window.store = Redux.createStore(function(state, action){
  if (!state) state = {};

  switch (action.type) {

    case actions.receiveRecords:
      return Object.assign({}, state, {
        Account: Object.assign({}, state.Account, action.records.Account),
        AccountEntry: Object.assign({}, state.AccountEntry, action.records.AccountEntry),
        BankEntry: Object.assign({}, state.BankEntry, action.records.BankEntry)
      });

    case '@@redux/INIT':
    case actions.requestAccounts:
    case actions.requestAccount:
      // noop
      return state;

    default:
      console.log(`Unknown action.type ${action.type}`);
      return state;

  }
}, {}, Redux.applyMiddleware(
  function(opts){
    return next => action =>
      typeof action === 'function' ?
        action(opts.dispatch, opts.getState) :
        next(action);
  }
));
