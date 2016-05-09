/* globals React ReactDOM jQuery */
/* eslint no-unused-vars: ["error", { "varsIgnorePattern": "^(App|Users|Ledgers)$" }] */
//= require react
//= require jquery

function Users(props){
  var users = props.users;

  return <div>
    <h3>Users</h3>
    <table>
      <thead>
        <tr>
          <th>Name</th><th>Gmail</th><th>Ledger</th>
        </tr>
      </thead>
      <tbody>
        { users.map(function(user){
          return <tr key={ user.id }>
            <td>{ user.name }</td><td>{ user.email }</td><td>{ user.ledger }</td>
          </tr>;
        }) }
      </tbody>
    </table>
  </div>;
}

function Ledgers(props){
  var users = props.users;
  var ledgers = props.ledgers;

  return <div>
    <h3>Ledgers</h3>
    <table>
      <thead>
        <tr>
          <th>Name</th><th>Users</th>
        </tr>
      </thead>
      <tbody>
        { ledgers.map(function(ledger){
          var ledgerUsers = users
            .filter(function(user){
              return user.ledger === ledger;
            })
            .map(function(user){ return user.name; })
            .join(', ');
          return <tr key={ ledger }>
            <td>{ ledger }</td><td>{ ledgerUsers }</td>
          </tr>;
        }) }
      </tbody>
    </table>
  </div>;
}

var App = React.createClass({
  getInitialState: function(){
    return { users: [], ledgers: [] };
  },

  componentDidMount: function(){
    jQuery.post({
      url: '/api',
      context: this
    }, JSON.stringify([
      {reference: 'users', resource: 'User_v1', action: 'read'},
      {reference: 'ledgers', resource: 'Ledger_v1', action: 'read'}
    ])).then(function(data){
      var users = data.records['User'];
      var ledgerResponse = data.responses.find(function(response){ return response.reference === 'ledgers'; });
      this.setState({
        users: Object.keys(users).map(function(id){ return users[id]; }),
        ledgers: ledgerResponse.data
      });
    });
  },

  render: function(){
    return <div>
      <Users users={ this.state.users } ledgers={ this.state.ledgers } />
      <Ledgers users={ this.state.users } ledgers={ this.state.ledgers } />
    </div>;
  }
});

var app = document.querySelector('.app');
ReactDOM.render(<App />, app);
