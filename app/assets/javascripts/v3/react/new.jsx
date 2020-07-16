function formatCurrency(amountCents) {
  // return ('$' + number).replace(/(\d)(?=\d{2}$)/, '$1.').replace(/(\d)(?=(\d{3})+$)/g, '$1,');
  // return String(number).replace(/(\d)(?=(\d{3})+$)/g, '$1,');
  let [_, sign, dollars, cents ] = String(amountCents / 100).match(/(-)?(\d+)(?:\.(\d+))?/);
  dollars = dollars.replace(/(\d)(?=(\d{3})+$)/g, '$1,');
  cents = ((cents || '') + '00').substr(0,2);

  return `$${sign || ''}${dollars}.${cents}`;
}

const nth = n => [,'st','nd','rd'][n%100>>3^1&&n%10]||'th';
const frequencies = 'year month week day hour minute second'.split(' ');
function rruleToText(rrule) {
  const { interval, freq, bymonthday } = RRule.fromString(rrule).options;
  return `${
    interval === 1 ? 'every' : `${interval} times a`
  } ${frequencies[freq]}${
    bymonthday ? ` on the ${bymonthday}${nth(bymonthday)}` : ''
  }`;
}

class V3React extends React.PureComponent {
  constructor() {
    super();
    // this.state = { users: [], ledgers: [] };
    // this.createUser = this.createUser.bind(this);
    // this.deleteUser = this.deleteUser.bind(this);
    // this.createLedger = this.createLedger.bind(this);
    // this.deleteLedger = this.deleteLedger.bind(this);
    // this.state = { bankEntries: [] };
    // this.state = { accounts: [] };
    this.state = { projectedEntries: [] }
    // this.generateForecastedEntries = this.generateForecastedEntries.bind(this);
    this.handleProjectedEntry = this.handleProjectedEntry.bind(this);
  }

  componentDidMount(){
    // this.fetchBankEntries();
    this.fetchProjectedEntries();
  }

  generateForecastedEntries(){
    const { projectedEntries, accounts } = this.state;
    const day = 24 * 60 * 60 * 1000;
    const today = new Date;
    today.setHours(0);
    today.setMinutes(0);
    today.setSeconds(0);
    // const monthAndHalf = new Date(today.getTime() + 2.5 * 30 * day);
    const bitOverAYear =  new Date(today.getTime() + 400 * day);

    const forecastedEntries = projectedEntries
      .map(({ id, rrule }) => {
        try {
          return RRule.fromString(rrule).between(today, bitOverAYear)
            .map((date, index) => ({ projectedEntryId: id, date, first: index === 0 }));
        } catch (e) {
          return [{ projectedEntryId: id, first: true }];
        }
      })
      .reduce((a,b) => a.concat(b), [])
      .sort(({ date: aDate }, { date: bDate }) =>
        aDate === undefined ? -1 :
        bDate === undefined ? 1 :
        aDate - bDate
      );

    this.setState({ forecastedEntries });
  }

  fetchProjectedEntries(){
    fetch('/graphql', {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ query: `{
        accounts { id name balanceCents }
        projectedEntries {
          id
          description
          amountCents
          rrule
          account { id }
        }
      }` })
    })
    .then(r => r.json())
    .then(j => { console.log('json', window.json = j); return j; })
    .then(({ data: { projectedEntries, accounts } }) => {
      this.setState({ projectedEntries, accounts });
      this.generateForecastedEntries();
    })
    .catch(console.error);
  }

  handleProjectedEntry(id, projectedEntry) {
    this.setState(({ projectedEntries }) => {
      const index = projectedEntries.findIndex(pe => pe.id === id);
      console.log('handleProjectedEntry', id, projectedEntry, index);

      if (index === -1) return { projectedEntries: projectedEntries.concat(projectedEntry) };
      return { projectedEntries: [
        ...projectedEntries.slice(0, index),
        ...( projectedEntry ? [projectedEntry] : [] ),
        ...projectedEntries.slice(index + 1),
      ] }
    }, () => {
      console.log('projectedEntries', window.projectedEntries = this.state.projectedEntries);
      this.generateForecastedEntries();
    });
  }

  render() {
    const { accounts, projectedEntries, forecastedEntries } = this.state;

    if (!forecastedEntries) return <div>Loading ...</div>;
    console.log('forcastedEntries', window.forecastedEntries = forecastedEntries);

    let sum = accounts.reduce((a, { balanceCents }) => a + balanceCents, 0);

    return <React.Fragment>
      <datalist id="frequency">
        { [
          'Every year',
          'Every month'
        ].map(option => <option key={option} value={option} />) }
      </datalist>
      <datalist id="accounts">
        { accounts.map(({ name }) => <option key={name} value={name} />) }
      </datalist>
      <table className="forecast">
        <thead>
          <tr>
            <th>date</th>
            <th>description</th>
            <th>frequency</th>
            <th>account</th>
            <th>amount</th>
            <th>balance</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>{ (new Date).toLocaleDateString() }</td>
            <td />
            <td />
            <td />
            <td />
            <td>{ formatCurrency(sum) }</td>
          </tr>
          <ProjectedEntryForm onChange={this.handleProjectedEntry} />
          { forecastedEntries.map(({ projectedEntryId, date, first }) => {
              const { id, description, amountCents, rrule, account: { id: accountId } } = projectedEntries.find(({ id }) => id === projectedEntryId);
              const account = accounts.find(({ id }) => id === accountId);
              sum -= amountCents;

              if (first) return <ProjectedEntryForm key={date ? `${id} ${date.toJSON()}` : id}
                onChange={this.handleProjectedEntry}
                {...{ id, date, description, rrule, account, amountCents, sum }}
              />;

              return <tr key={`${id}-${date}`}>
                <td>{ date.toLocaleDateString() }</td>
                <td>{ description }</td>
                <td>{ rruleToText(rrule).replace(/^[a-z]/, s => s.toUpperCase()) }</td>
                <td>{ account.name }</td>
                <td>{ formatCurrency(amountCents) }</td>
                <td>{ formatCurrency(sum) }</td>
              </tr>;
            })
          }
        </tbody>
      </table>
    </React.Fragment>;
  }
}

class ProjectedEntryForm extends React.PureComponent {
  constructor(props) {
    super(props);
    this.formRef = React.createRef();
    this.onSubmit = this.onSubmit.bind(this);
    this.onDelete = this.onDelete.bind(this);
  }

  onSubmit() {
    const { id, onChange } = this.props;
    const formElements = [...this.formRef.current.querySelectorAll('input[name], select[name]')];
    const props = formElements.reduce((acc,input) => ({
      ...acc,
      [input.name]: input.value
    }), {});
    const rule = new RRule({ dtstart: new Date(props.date), freq: props.frequency, until: null });
    delete props.date;
    delete props.frequency;
    fetch('/graphql', {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ query: `
        mutation CreateProjectedEntry {
          addProjectedEntryMutation(input:{ 
            account:"${props.account}",
            description:"${props.description}",
            amountCents:${props.amount.replace(/(^\$|,)/, '')*100},
            rrule:"${rule.toString()}"
          }) {
            projectedEntry {
              id
              description
              amountCents
              rrule
              account { id }
            }
          }
        }
      ` })
    })
    .then(r => r.json())
    .then(j => { console.log('json', window.json = j); return j; })
    .then(({ data: { addProjectedEntryMutation: { projectedEntry } } }) => {
      this.props.onChange(projectedEntry.id, projectedEntry);
      if (!id) formElements.forEach(el => el.value = el.defaultValue);
    })
    .catch(console.error);
  }

  onDelete() {
    fetch('/graphql', {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ query: `
        mutation DeleteProjectedEntry {
          deleteProjectedEntryMutation(input:{
            id:${this.props.id}
          }) {
            projectedEntry { id }
          }
        }
      ` })
    })
    .then(r => r.json())
    .then(j => { console.log('json', window.json = j); return j; })
    .then(({ data: { deleteProjectedEntryMutation: { projectedEntry: { id } } } }) => {
      this.props.onChange(id, null);
    });
  }

  render() {
    const { id, date, description, rrule, account, amountCents, sum } = this.props;
    const { freq } = RRule.fromString(rrule || '').options;

    return <tr ref={this.formRef}>
      <td><input type="date" name="date"                       defaultValue={date ? date.toJSON().slice(0, 10) : ''}  /></td>
      <td><input             name="description"                defaultValue={description}                             /></td>
      <td>
        <select name="frequency" defaultValue={freq}>
          {RRule.FREQUENCIES.map((frequency, index) => <option key={index} value={index}>{frequency}</option>)}
        </select>
      </td>
      <td><input             name="account"   list="accounts"  defaultValue={account ? account.name : ''}             /></td>
      <td><input             name="amount"                     defaultValue={formatCurrency(amountCents || '')}       /></td>
      <td>{ formatCurrency(sum || '')                                                                                  }</td>
      <td>
        <button onClick={this.onSubmit}>{ id ? 'update' : 'create'  }</button>
        { id ? <button onClick={this.onDelete}>delete</button> : null }
      </td>
    </tr>;
  }
}

var app = document.querySelector('.app');
if (app) ReactDOM.render(<V3React />, app);
