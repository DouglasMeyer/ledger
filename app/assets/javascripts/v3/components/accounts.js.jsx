var Provider = ReactRedux.Provider;

angular.module('ledger').value('AccountsComponent', React.createClass({
  displayName: 'AccountsComponent',

  render: function(){
    return (
      <Provider store={store}>
        <Accounts />
      </Provider>
    );
  }
}));

function formatCurrency(cents){
  dollars = cents / 100;
  return dollars.toLocaleString('en-US', {style:'currency', currency: 'USD'});
}

function Account(props){
  var account = props.account;
  return (
    <div key={ account.id } className="m-line" is l-flex="between">
      <a href={ "/v3/accounts/" + account.id }>{ account.name }</a>
      <span is class={ 'm-balance' + (account.balance_cents < 0 ? ' is-negative' : '') } l-width="5" l-margin="r1" t-align="right">
        { formatCurrency(account.balance_cents) }
      </span>
    </div>
  );
}

function Category(props){
  var accounts = props.accounts,
      accountViews = accounts
        .map(a=>a.category)
        .filter((category,index,self)=>self.indexOf(category) === index)
        .map(category => {
          const accountViews = accounts
            .filter(a => a.category == category)
            .map(account => <Account account={account} />);

          return (
            <div key={ category } className="m-category">
              <h4 className="m-line" is l-flex>{ category }</h4>
              { accountViews }
            </div>
          );
        });

  return (
    <div>
      <h2 is t-align="center">{ props.title }</h2>
      { accountViews }
    </div>
  );
}

var Accounts = ReactRedux.connect(s=>s)(React.createClass({
  displayName: 'Accounts',

  propTypes: {
    dispatch: React.PropTypes.func.isRequired
  },

  componentDidMount: function(){
    const { dispatch } = this.props;
    dispatch(actions.ensureAccounts());
  },

  render: function(){
    if (!this.props.accounts) return false;
    const
      assetAccounts = this.props.accounts
        .filter(a=> !a.deleted_at && a.asset)
        .sort((a,b)=> a.position - b.position),
      liabilityAccounts = this.props.accounts
        .filter(a=> !a.deleted_at && !a.asset)
        .sort((a,b)=> a.position - b.position);
    return (
      <div is l-flex="wrap center" l-margin="b3">
        <Category accounts={assetAccounts} title="Asset" is l-margin="r2" />
        <Category accounts={liabilityAccounts} title="Liability" />
      </div>
    );
  }
}));
