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

var Accounts = ReactRedux.connect(s=>s)(React.createClass({
  displayName: 'Accounts',

  propTypes: {
    dispatch: React.PropTypes.func.isRequired
  },

  componentDidMount: function(){
    const { dispatch } = this.props;
    dispatch(actions.ensureAccounts());
  },

  renderCategories: function(accounts){
    return accounts
      .map(a=>a.category)
      .filter((category,index,self)=>self.indexOf(category) === index)
      .map(category => {
        const accountViews = accounts
          .filter(a => a.category == category)
          .map(account => {
            return (
              <div key={ account.id } className="m-line" is l-flex="between">
                <a href={ "/v3/accounts/" + account.id }>{ account.name }</a>
                <span className="m-balance" is l-width="5" l-margin="r1" t-align="right">
                  { account.balance_cents }
                </span>
              </div>
            );
          });
        return (
          <div key={ category } className="m-category">
            <h4 className="m-line" is l-flex>{ category }</h4>
            { accountViews }
          </div>
        );
      });
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
        <div is l-margin="r2">
          <h2 is t-align="center">Asset</h2>
          { this.renderCategories(assetAccounts) }
        </div>
        <div>
          <h2 is t-align="center">Liability</h2>
          { this.renderCategories(liabilityAccounts) }
        </div>
      </div>
    );
  }
}));
