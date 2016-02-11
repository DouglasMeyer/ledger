window.store = Redux.createStore(function(state, action){
  if (!state) state = {};

  switch (action.type) {

    case actions.receiveAccounts:
      return Object.assign({}, state, {
        accounts: action.accounts
      });

    case '@@redux/INIT':
    case actions.requestAccounts:
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
