'use babel';

let logger;

if (atom.inDevMode()) {
  logger = console;
} else {
  logger = {
    assert: () => {},
    clear: () => {},
    count: () => {},
    debug: () => {},
    dir: () => {},
    dirxml: () => {},
    error: () => {},
    group: () => {},
    groupCollapsed: () => {},
    groupEnd: () => {},
    info: () => {},
    log: () => {},
    markTimeLine: () => {},
    memory: {},
    profile: () => {},
    profileEnd: () => {},
    table: () => {},
    time: () => {},
    timeEnd: () => {},
    timeStamp: () => {},
    timeline: () => {},
    timelineEnd: () => {},
    trace: () => {},
    warn: () => {}
  };
}

module.exports = logger;
