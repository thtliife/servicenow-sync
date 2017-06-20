'use babel';
import ServicenowSyncPackage from './servicenow-sync-package';

let pkg;

const entryPoint = {
  initialize() {
    pkg = new ServicenowSyncPackage({
      workspace: atom.workspace,
      project: atom.project,
      commands: atom.commands,
      notifications: atom.notifications,
      tooltips: atom.tooltips,
      styles: atom.styles,
      grammars: atom.grammars,
      confirmation: atom.confirm.bind(atom),
      config: atom.config,
      configDir: atom.getConfigDirPath(),
      loadSettings: atom.getLoadSettings.bind(atom)
    });
  }
};

export default new Proxy(entryPoint, {
  get(target, name) {
    if (pkg && Reflect.has(pkg, name)) {
      let item = pkg[name];
      if (typeof item === 'function') {
        item = item.bind(pkg);
      }
      return item;
    }
    return target[name];
  }
});
