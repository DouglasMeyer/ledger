"use strict";
window.actions = {};

(function(){
  // generic records
  actions.receiveRecords = 'Receive Records';
  function receiveRecords(records){
    return {
      type: actions.receiveRecords,
      records: records,
    }
  }

  // Accounts
  let accountsFetchedOn;
  function shouldFetchAccounts(state){
    if (!state.Account) return 'No Accounts';
    if (!accountsFetchedOn) return "Accounts haven't be explicitly fetched";
    if (accountsFetchedOn < Date.now() - 60*1000) return "Account haven't been fetched for a minute";
    return false;
  }

  actions.requestAccounts = 'Request Accounts';
  function requestAccounts(){
    accountsFetchedOn = Date.now();
    return {
      type: actions.requestAccounts
    }
  }

  function fetchAccounts(){
    return dispatch => {
      dispatch(requestAccounts());
      var data = JSON.stringify([{ action: 'read', resource: 'Account_v1' }])
      jQuery.post('/api', data)
        .then(json => json.records)
        .then(records =>{ dispatch(receiveRecords(records)); })
    }
  }

  actions.ensureAccounts = ensureAccounts;
  function ensureAccounts(){
    return (dispatch, getState) => {
      if (shouldFetchAccounts(getState())){
        return dispatch(fetchAccounts());
      }
    }
  }


  // Account
  const accountFetchedOn = {};
  function shouldFetchAccount(state, id){
    if (!state.Account) return "No Accounts";
    if (!state.Account[id]) return "No Account";
    const fetchedOn = accountFetchedOn[id];
    if (!fetchedOn) return "Account hasn't been explicitly fetched";
    if (fetchedOn < Date.now() - 60*1000) return "Account hasn't been fetched for a minute";
    return false;
  }

  actions.requestAccount = 'Request Account';
  function requestAccount(id){
    accountFetchedOn[id] = Date.now();
    return {
      type: actions.requestAccount,
      id
    }
  }

  function fetchAccount(id){
    return dispatch => {
      dispatch(requestAccount(id));
      var data = JSON.stringify([{ action: 'read', resource: 'Account_v1', query: { id: [id] }, include: ['account_entries.with_balance'] }])
      jQuery.post('/api', data)
        .then(json => json.records)
        .then(records =>{ dispatch(receiveRecords(records)); })
    }
  }

  actions.ensureAccount = ensureAccount;
  function ensureAccount(id){
    return (dispatch, getState) => {
      if (shouldFetchAccount(getState(), id)){
        return dispatch(fetchAccount(id));
      }
    }
  }
})();
