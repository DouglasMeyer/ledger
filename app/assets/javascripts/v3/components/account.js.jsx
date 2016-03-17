(function(){
  var Provider = ReactRedux.Provider;

  angular.module('ledger').value('AccountComponent', React.createClass({
    displayName: 'AccountComponent',

    render: function(){
      return (
        <Provider store={store}>
          <Account id={this.props.id} />
        </Provider>
      );
    }
  }));


  function AccountEntry(props){
    const accountEntry = props.accountEntry,
          bankEntry = accountEntry.bank_entry;
    return (
      <div is l-flex="center">
        <div is l-width="6" class="m-underline">{ bankEntry.date }</div>
        <div is l-width="30" class="m-underline">{ bankEntry.description }</div>
        <div is l-width="6" t-align="right" class={ 'm-underline m-balance' + (accountEntry.amount_cents < 0 ? ' is-negative' : '') }>
          { formatCurrency(accountEntry.amount_cents) }
        </div>
        <div is l-width="6" t-align="right" class={ 'm-underline m-balance' + (accountEntry.balance_cents < 0 ? ' is-negative' : '') }>
          { formatCurrency(accountEntry.balance_cents) }
        </div>
      </div>
    );
  }

  var Account = ReactRedux.connect(s=>s)(React.createClass({
    displayName: 'Account',

    propTypes: {
      dispatch: React.PropTypes.func.isRequired,
      id: React.PropTypes.any.isRequired
    },

    componentDidMount: function(){
      const { dispatch, id } = this.props;
      dispatch(actions.ensureAccount(id));
    },

    render: function(){
      const { Account, AccountEntry: AE, BankEntry: BE, id } = this.props;
      if (!Account || !AE) return false;
      const account = Account[id],
            accountEntries = Object.values(AE)
              .filter(ae=>ae.account_id === account.id);
      accountEntries
        .forEach(ae=>ae.bank_entry = BE[ae.bank_entry_id]);
      const sortedAEs = accountEntries
              .sort((a,b)=>{
                if (a.bank_entry.date < b.bank_entry.date) return 1;
                if (a.bank_entry.date > b.bank_entry.date) return -1;
                if (a.bank_entry.id < b.bank_entry.id) return 1;
                if (a.bank_entry.id > b.bank_entry.id) return -1;
                return 0;
              });
      return (
        <div is t-align="center">
          <h2>
            { account.name }
            <span is class={ 'm-balance' + (account.balance_cents < 0 ? ' is-negative' : '') } l-margin="l2">
              { formatCurrency(account.balance_cents) }
            </span>
          </h2>
          <div is t-align="left">
            { sortedAEs.map(ae =>{
              return (
                <AccountEntry key={ae.id} accountEntry={ae} />
              );
            }) }
          </div>
        </div>
      );
    }
  }));
})();
