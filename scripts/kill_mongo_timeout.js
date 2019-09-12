const currentOp = db.currentOp({ active: true, secs_running: { $gt: 30 } });
for (op in currentOp.inprog) {
  if ("192.168.1.10" == currOp.inprog[op].client.split(":")[0])
    {
      db.killOp(currOp.inprog[op].opid);
    }
}