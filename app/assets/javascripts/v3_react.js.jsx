/* globals React ReactDOM jQuery */
/* eslint no-unused-vars: ["error", { "varsIgnorePattern": "^(App|Users|Ledgers)$" }] */
//= require react
//= require jquery

var Users = React.createClass({
  getInitialState: function(){
    return { newName: '', newEmail: '', newLedger: '' };
  },

  onInputChange: function(e){
    var stateUpdates = {};
    stateUpdates[e.target.name] = e.target.value;
    this.setState(stateUpdates);
  },

  onCreateUser: function(){
    var state = this.state;
    this.props.onCreateUser(state.newName, state.newEmail, state.newLedger);
    this.setState({ newName: '', newEmail: '', newLedger: '' });
  },

  render: function(){
    var users = this.props.users;
    var ledgers = this.props.ledgers;
    var newName = this.state.newName;
    var newEmail = this.state.newEmail;
    var newLedger = this.state.newLedger;

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
          <tr>
            <td>
              <input placeholder='name' name='newName' value={ newName } onChange={ this.onInputChange } />
            </td>
            <td>
              <input placeholder='email' name='newEmail' value={ newEmail } onChange={ this.onInputChange } />
            </td>
            <td>
              <select name='ledger' name='newLedger' value={ newLedger } onChange={ this.onInputChange }>
                <option />
                { ledgers.map(function(ledger){
                  return <option key={ ledger } value={ ledger }>{ ledger }</option>;
                }) }
              </select>
            </td>
            <td>
              <input type='submit' value='Add User' onClick={ this.onCreateUser } />
            </td>
          </tr>
        </tbody>
      </table>
    </div>;
  }
});

var Ledgers = React.createClass({
  getInitialState: function(){
    return { newLedger: '' };
  },

  onInputChange: function(e){
    var stateUpdates = {};
    stateUpdates[e.target.name] = e.target.value;
    this.setState(stateUpdates);
  },

  onCreateLedger: function(){
    this.props.onCreateLedger(this.state.newLedger);
    this.setState({ newLedger: '' });
  },

  render: function(){
    var users = this.props.users;
    var ledgers = this.props.ledgers;
    var newLedger = this.state.newLedger;

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
          <tr>
            <td>
              <input name='newLedger' placeholder='name' value={ newLedger } onChange={ this.onInputChange }/>
            </td>
            <td>
              <input type='submit' value='Add Ledger' onClick={ this.onCreateLedger } />
            </td>
          </tr>
        </tbody>
      </table>
    </div>;
  }
});

var API = (function(){
  var requests = [];
  var resolves = {};
  var requestTimeout;

  function doAPI(){
    jQuery.post({ url: '/api', context: resolves }, JSON.stringify(requests))
      .then(function(data){
        data.responses.forEach(function(response){
          this[response.reference]({ response: response, records: data.records });
        }, this);
      });
    requests = [];
    resolves = {};
  }

  return function API(request){
    request.reference = request.reference || Math.random().toString();
    requests.push(request);
    if (requestTimeout) clearTimeout(requestTimeout);
    requestTimeout = setTimeout(doAPI, 100);
    var deferred = Promise.defer();
    resolves[request.reference] = deferred.resolve;
    return deferred.promise;
  };
})();

var App = React.createClass({
  getInitialState: function(){
    return { users: [], ledgers: [] };
  },

  componentDidMount: function(){
    this.fetchUsersAndLedgers();
  },

  fetchUsersAndLedgers: function(){
    Promise.all([
      API({ reference: 'users', resource: 'User_v1', action: 'read' }),
      API({ reference: 'ledgers', resource: 'Ledger_v1', action: 'read' })
    ]).then(function(responses){
      var userResponse = responses[0].response;
      var ledgerResponse = responses[1].response;
      var records = responses[0].records;

      this.setState({
        users: userResponse.records.map(function(record){ return records[record.type][record.id]; }),
        ledgers: ledgerResponse.data
      });
    }.bind(this));
  },

  createUser: function(name, email, ledger){
    API({ resource: 'User_v1', action: 'create', data: {
      name: name, provider: 'google_oauth2', email: email, ledger: ledger
    }});
    this.fetchUsersAndLedgers();
  },

  createLedger: function(ledger){
    API({ resource: 'Ledger_v1', action: 'create', data: ledger });
    this.fetchUsersAndLedgers();
  },

  render: function(){
    return <div>
      <Users
        users={ this.state.users }
        ledgers={ this.state.ledgers }
        onCreateUser={ this.createUser }
      />
      <Ledgers
        users={ this.state.users }
        ledgers={ this.state.ledgers }
        onCreateLedger={ this.createLedger }
      />
    </div>;
  }
});

var app = document.querySelector('.app');
ReactDOM.render(<App />, app);
