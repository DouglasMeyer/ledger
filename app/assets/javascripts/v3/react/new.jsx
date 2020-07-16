const pipe = (...valNFns) => valNFns.reduce((val, fn) => fn(val));

const toCurrency = (amount) =>
  amount.toLocaleString("en", { style: "currency", currency: "USD" });

const monthAgo = new Date();
monthAgo.setMonth(monthAgo.getMonth() - 1);

const dateFmt = (date) => date.toLocaleDateString("fr-CA");

const useTransform = (timing) => {
  const elRef = React.useRef();
  const prevBounds = React.useRef();
  React.useLayoutEffect(() => {
    const bounds = elRef.current.getBoundingClientRect();
    if (prevBounds.current) {
      elRef.current.animate(
        [
          {
            transform: `translate(${prevBounds.current.left - bounds.left}px, ${
              prevBounds.current.top - bounds.top
            }px)`,
            clipPath: `polygon(0 0, ${prevBounds.current.width}px 0, ${prevBounds.current.width}px ${prevBounds.current.height}px, 0 ${prevBounds.current.height}px)`,
            overflow: "visible",
          },
          {
            transform: "translate(0, 0)",
            clipPath: `polygon(0 0, ${bounds.width}px 0, ${bounds.width}px ${bounds.height}px, 0 ${bounds.height}px)`,
            overflow: "visible",
          },
        ],
        timing
      );
    }
    prevBounds.current = bounds;
  });
  return elRef;
};

const Account = ({
  account,
  bankEntries,
  balance,
  highlighted,
  selected,
  onClick,
}) => {
  const elRef = useTransform({ duration: 300, easing: "ease" });
  const handleClick = React.useCallback((e) => {
    e.preventDefault();
    onClick(account);
  });
  const accountEntries = [];
  bankEntries.forEach((bankEntry) => {
    bankEntry.accountEntries.forEach((accountEntry) => {
      if (accountEntry.account.name === account)
        accountEntries.push(accountEntry);
    });
  });

  return (
    <div
      ref={elRef}
      className={`Account${highlighted ? " highlighted" : ""}${
        selected ? " selected" : ""
      }`}
    >
      <a href="#" onClick={handleClick}>
        {account} {toCurrency(balance / 100)}
      </a>
      <div>
        Last Month Spent:{" "}
        {toCurrency(
          accountEntries
            .filter((e) => e.date > monthAgo && e.amountCents < 0)
            .reduce((a, e) => a + e.amountCents, 0) / 100
        )}
      </div>
    </div>
  );
};
const Entry = ({ isSelected, onClick, previousEntry, entry }) => {
  const { amountCents, date, accountEntries } = entry;
  const from = accountEntries.filter(({ amountCents }) => amountCents < 0);
  const to = accountEntries.filter(({ amountCents }) => amountCents > 0);
  const amount =
    amountCents === 0
      ? from.reduce((sum, { amountCents }) => sum + amountCents, 0)
      : amountCents;
  const handleClick = React.useCallback(() => {
    onClick(entry);
  }, []);
  return (
    <React.Fragment>
      <div onClick={handleClick}>
        {!previousEntry || previousEntry.date !== date ? date : null}
      </div>
      <div onClick={handleClick}>
        {amountCents === 0 ? "↔" : amount < 0 ? "←" : "→"}
      </div>
      <div onClick={handleClick}>{toCurrency(amount / 100)}</div>
      <div onClick={handleClick} className={isSelected ? "selected" : ""}>
        {from.length
          ? `from ${from.map(({ account: { name } }) => name).join(", ")}`
          : ""}
        {to.length
          ? ` to ${to.map(({ account: { name } }) => name).join(", ")}`
          : ""}
      </div>
    </React.Fragment>
  );
};
const EntryForm = ({ entry, accounts, isOpen, onClose, onSave }) => {
  const [editingEntry, setEditingEntry] = React.useState({});
  React.useEffect(() => {
    console.log(entry);
    setEditingEntry(entry || {});
  }, [isOpen, entry]);
  const handleChange = React.useCallback(({ target: { name, value } }) => {
    setEditingEntry((entry) => Object.assign({}, entry, { [name]: value }));
  }, []);
  const handleCancel = React.useCallback((event) => {
    event.preventDefault();
    onClose();
  }, []);
  const date = (function (year, month, day) {
    if (!year) return new Date();
    return new Date(year, month - 1, day);
  })(...(editingEntry.date ? editingEntry.date.split("-") : [null]));

  return (
    <div className={`EntryForm${isOpen ? " open" : ""}`}>
      <input
        type="date"
        name="date"
        value={dateFmt(date)}
        onChange={handleChange}
      />
      <div>{editingEntry.amount < 0 ? "←" : "→"}</div>
      <input
        name="amount"
        value={editingEntry.amount || ""}
        onChange={handleChange}
      />
      <div>
        <input
          name="account"
          list="accounts"
          value={editingEntry.account || ""}
          onChange={handleChange}
        />
        <datalist id="accounts">
          {accounts.map((account) => (
            <option key={account} value={account} />
          ))}
        </datalist>
        <a href="#" onClick={handleCancel}>
          cancel
        </a>
        <button onClick={onSave}>Save</button>
      </div>
    </div>
  );
};
const V3React = () => {
  const [selectedAccount, selectAccount] = React.useState();
  const [selectedEntity, setSelectedEntity] = React.useState();
  const [entriesOffset, setEntriesOffset] = React.useState(0);
  const handleScroll = React.useCallback((event) => {
    const offset = Math.max(0, Math.floor((event.target.scrollTop + 8) / 36));
    setEntriesOffset(offset);
  }, []);
  const [accountBalances, setAccountBalances] = React.useState();
  const [bankEntries, setBankEntries] = React.useState();
  const [bankEntryOffset, setBankEntryOffset] = React.useState(0);
  const entriesBottomRef = React.useRef();

  React.useEffect(
    function () {
      if (!entriesBottomRef.current) return;
      const observer = new IntersectionObserver(function (entries) {
        if (entries[0].intersectionRatio <= 0) return;

        setBankEntryOffset((offset) => offset + bankEntries.length);
      });
      observer.observe(entriesBottomRef.current);
      return () => observer.disconnect();
    },
    [bankEntries]
  );
  React.useEffect(
    function () {
      fetch("/graphql", {
        method: "POST",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          query: `{
        accounts { name balanceCents }
        ${
          /*projectedEntries {
          id
          description
          amountCents
          rrule
          account { id, name }
        }*/ ""
        }
        bankEntries(first: 50, after: ${bankEntryOffset}${
            selectedAccount ? `, account: "${selectedAccount}"` : ""
          }) {
          accountEntries {
            ${/*id, account { id, name }, amountCents*/ ""}
            id, account { name }, amountCents
          },
          amountCents,
          date,
          id
        }
      }`,
        }),
      })
        .then((r) => r.json())
        .then(
          ({
            data: { projectedEntries, accounts, bankEntries: newBankEntries },
          }) => {
            pipe(
              accounts.map(({ name, balanceCents }) => [name, balanceCents]),
              Object.fromEntries,
              setAccountBalances
            );
            setBankEntries((bankEntries) =>
              (bankEntries || []).concat(newBankEntries)
            );
          }
        );
    },
    [selectedAccount, bankEntryOffset]
  );
  const filteredEntries = React.useMemo(
    () =>
      bankEntries &&
      bankEntries.filter(
        ({ accountEntries }) =>
          !selectedAccount ||
          accountEntries.some(
            ({ account: { name } }) => name === selectedAccount
          )
      ),
    [bankEntries, selectedAccount]
  );
  const accounts = React.useMemo(() => {
    if (!bankEntries) return;
    const accounts = {};
    bankEntries.slice().forEach(({ accountEntries }) => {
      accountEntries.forEach(({ account: { name } }) => {
        accounts[name] = 0;
      });
    });
    Object.assign(accounts, accountBalances);
    filteredEntries.slice(0, entriesOffset).forEach(({ accountEntries }) => {
      accountEntries.forEach(({ account: { name }, amountCents }) => {
        accounts[name] -= amountCents;
      });
    });
    return Object.entries(accounts);
  }, [entriesOffset, filteredEntries, accountBalances]);
  const previousEntry = filteredEntries && filteredEntries[entriesOffset];
  const handleAccountClick = React.useCallback(
    (name) => {
      selectAccount(name === selectedAccount ? null : name);
      setBankEntries();
    },
    [selectedAccount]
  );

  if (!bankEntries) return "Loading";

  return (
    <React.Fragment>
      <div className="accounts">
        {accounts
          .filter(
            ([account]) => !selectedAccount || account === selectedAccount
          )
          .map(([account, balance]) => (
            <Account
              key={account}
              highlighted={
                previousEntry &&
                previousEntry.accountEntries.some(
                  ({ account: { name } }) => name === account
                )
              }
              selected={account === selectedAccount}
              account={account}
              bankEntries={bankEntries}
              balance={balance}
              onClick={handleAccountClick}
            />
          ))}
      </div>
      <div className="entries" onScroll={handleScroll}>
        {filteredEntries.map((entry, entryIndex) => (
          <Entry
            key={entry.id}
            entry={entry}
            previousEntry={filteredEntries[entryIndex - 1]}
            isSelected={entry === selectedEntity}
            onClick={setSelectedEntity}
          />
        ))}
        <div className="entries-bottom" ref={entriesBottomRef} />
      </div>
      <EntryForm
        isOpen={Boolean(selectedEntity)}
        entry={selectedEntity}
        accounts={accounts.map(([name]) => name)}
        onSave={console.log.bind(null, "onSave")}
        onClose={() => setSelectedEntity(null)}
      />
    </React.Fragment>
  );
};

const app = document.querySelector(".app");
if (app) ReactDOM.render(<V3React />, app);
