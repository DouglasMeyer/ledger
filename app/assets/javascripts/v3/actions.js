// Accounts
function shouldFetchAccounts(state){
  const accounts = state.accounts;
  if (!accounts){
    return true;
  } else if (accounts.isFetching) {
    return false;
  } else {
    return false;
  }
}

function requestAccounts(){
  return {
    type: actions.requestAccounts,
    requestedOn: Date.now()
  }
}

function receiveAccounts(accounts){
  return {
    type: actions.receiveAccounts,
    accounts: accounts,
    receivedAt: Date.now()
  }
}

function fetchAccounts(){
  return dispatch => {
    dispatch(requestAccounts());
    var init = {
      method: 'post',
      body: JSON.stringify([{ action: 'read', resource: 'Account_v1' }]),
      headers: new Headers()
    };
    init.headers.append('X-Requested-With', 'XMLHttpRequest');
    return fetch('/api', init)
      .then(req => req.json())
      .then(json => json.responses[0].records.map(obj => json.records[obj.type][obj.id]))
      .then(records =>{ dispatch(receiveAccounts(records)); })
  }
}

function ensureAccounts(){
  return (dispatch, getState) => {
    if (shouldFetchAccounts(getState())){
      return dispatch(fetchAccounts());
    }
  }
}

actions = {
  requestAccounts: 'Request Accounts',
  receiveAccounts: 'Receive Accounts',
  ensureAccounts
}
