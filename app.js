// SmartBank frontend demonstration.
// This file uses browser-side sample data; it is not connected to Oracle Live SQL.
const initialAccounts = [
  { id: 1001, name: "Rahul Sharma", type: "SAVINGS", balance: 10000, opened: "28 Oct 2026" },
  { id: 1002, name: "Priya Verma", type: "SAVINGS", balance: 5000, opened: "28 Oct 2026" },
  { id: 1003, name: "Aman Singh", type: "CURRENT", balance: 20000, opened: "28 Oct 2026" }
];
let accounts = JSON.parse(localStorage.getItem("smartbank_accounts") || "null") || initialAccounts.map(a => ({...a}));
let transactions = JSON.parse(localStorage.getItem("smartbank_transactions") || "[]");
let audit = JSON.parse(localStorage.getItem("smartbank_audit") || "[]");
let currentAction = "deposit";
const fmt = n => new Intl.NumberFormat("en-IN", {style:"currency", currency:"INR", minimumFractionDigits:2}).format(n);
const byId = id => document.getElementById(id);
function save(){ localStorage.setItem("smartbank_accounts", JSON.stringify(accounts)); localStorage.setItem("smartbank_transactions", JSON.stringify(transactions)); localStorage.setItem("smartbank_audit", JSON.stringify(audit)); }
function escapeHtml(s){ return String(s).replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c])); }
function render(){
  byId("total-balance").textContent = fmt(accounts.reduce((s,a)=>s+a.balance,0));
  byId("account-count").textContent = accounts.length;
  byId("transaction-count").textContent = transactions.length;
  const accountRows = accounts.map(a=>`<tr><td class="account-id">#${a.id}</td><td class="customer">${escapeHtml(a.name)}</td><td>${a.type}</td><td>${a.opened}</td><td class="money">${fmt(a.balance)}</td></tr>`).join("");
  byId("dashboard-accounts").innerHTML = accounts.map(a=>`<tr><td class="account-id">#${a.id}</td><td class="customer">${escapeHtml(a.name)}</td><td>${a.type}</td><td class="money">${fmt(a.balance)}</td><td><span class="pill">Active</span></td></tr>`).join("");
  byId("accounts-table").innerHTML = accountRows;
  byId("transactions-table").innerHTML = transactions.slice().reverse().map(t=>`<tr><td class="account-id">${t.ref}</td><td>${t.date}</td><td>#${t.accountId}</td><td>${t.type.replace("_"," ")}</td><td>${escapeHtml(t.description)}</td><td class="money">${fmt(t.amount)}</td></tr>`).join("");
  byId("empty-transactions").classList.toggle("hidden", transactions.length>0);
  byId("audit-table").innerHTML = audit.slice().reverse().map(a=>`<tr><td class="account-id">${a.ref}</td><td>${a.date}</td><td>#${a.accountId}</td><td>${fmt(a.oldBalance)}</td><td>${fmt(a.newBalance)}</td><td>${fmt(a.newBalance-a.oldBalance)}</td></tr>`).join("");
  byId("empty-audit").classList.toggle("hidden", audit.length>0);
  fillAccountSelects();
}
function fillAccountSelects(){
  const options = accounts.map(a=>`<option value="${a.id}">#${a.id} — ${escapeHtml(a.name)} (${fmt(a.balance)})</option>`).join("");
  byId("account-select").innerHTML = options;
  byId("to-account-select").innerHTML = options;
}
function openView(view){
  document.querySelectorAll(".view").forEach(v=>v.classList.add("hidden"));
  byId(view).classList.remove("hidden");
  document.querySelectorAll(".nav-item").forEach(b=>b.classList.toggle("active", b.dataset.view===view));
  const titles = {dashboard:"Dashboard",accounts:"Accounts",transactions:"Transactions",audit:"Audit Log"};
  byId("page-title").textContent=titles[view] || "Dashboard";
}
function showToast(message){ const t=byId("toast");t.textContent=message;t.classList.remove("hidden");setTimeout(()=>t.classList.add("hidden"),2800); }
function openModal(action){
  currentAction=action;
  const labels={deposit:["Deposit money","Add money to the selected account."],withdraw:["Withdraw money","Withdraw from the selected account."],transfer:["Transfer funds","Move money from one account to another."]};
  byId("modal-title").textContent=labels[action][0];byId("modal-description").textContent=labels[action][1];
  byId("to-account-group").classList.toggle("hidden",action!=="transfer");
  byId("form-error").classList.add("hidden");byId("amount").value="";
  fillAccountSelects();byId("modal-backdrop").classList.remove("hidden");
}
function closeModal(){byId("modal-backdrop").classList.add("hidden");}
document.querySelectorAll("[data-view]").forEach(b=>b.addEventListener("click",()=>openView(b.dataset.view)));
document.querySelectorAll("[data-action]").forEach(b=>b.addEventListener("click",()=>openModal(b.dataset.action)));
byId("close-modal").addEventListener("click",closeModal);
byId("modal-backdrop").addEventListener("click",e=>{if(e.target===byId("modal-backdrop"))closeModal();});
byId("operation-form").addEventListener("submit",e=>{
  e.preventDefault();
  const fromId=Number(byId("account-select").value), toId=Number(byId("to-account-select").value), amount=Number(byId("amount").value);
  const from=accounts.find(a=>a.id===fromId), to=accounts.find(a=>a.id===toId), err=byId("form-error");
  const fail=message=>{err.textContent=message;err.classList.remove("hidden");};
  err.classList.add("hidden");
  if(!Number.isFinite(amount)||amount<=0)return fail("Enter an amount greater than zero.");
  if(currentAction==="transfer"&&fromId===toId)return fail("Choose two different accounts.");
  if((currentAction==="withdraw"||currentAction==="transfer")&&from.balance<amount)return fail("Insufficient balance. The operation was not completed.");
  const now=new Date().toLocaleString("en-IN");
  const addTransaction=(accountId,type,value,description)=>transactions.push({ref:"TXN"+String(Date.now()).slice(-7)+String(transactions.length+1),date:now,accountId,type,amount:value,description});
  const change=(a,delta)=>{const old=a.balance;a.balance=Number((a.balance+delta).toFixed(2));audit.push({ref:"AUD"+String(Date.now()).slice(-7)+String(audit.length+1),date:now,accountId:a.id,oldBalance:old,newBalance:a.balance});};
  if(currentAction==="deposit"){change(from,amount);addTransaction(from.id,"DEPOSIT",amount,"Cash deposit");}
  else if(currentAction==="withdraw"){change(from,-amount);addTransaction(from.id,"WITHDRAWAL",amount,"Cash withdrawal");}
  else {change(from,-amount);change(to,amount);addTransaction(from.id,"TRANSFER_OUT",amount,`Transfer to account ${to.id}`);addTransaction(to.id,"TRANSFER_IN",amount,`Transfer from account ${from.id}`);}
  save();render();closeModal();showToast("Operation completed in demo mode.");
});
render();
