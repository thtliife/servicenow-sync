'use babel';
import { CompositeDisposable, Disposable } from 'event-kit';
import path from 'path';
import React from 'react';
import ReactDOM from 'react-dom';

import { logger, fileExists, writeFile } from '../utilities';

const defaultState = {};

export default class ServicenowSyncPackage {
  constructor(environment) {
    Object.keys(environment).forEach(prop => {
      this[prop] = environment[prop];
    });
    this.configPath = path.join(this.configDir, 'servicenow-sync.json');
    this.startOpen = false;
    this.activated = false;
    this.subscriptions = new CompositeDisposable();

    this.subscriptions.add(
      atom.config.onDidChange(
        'servicenow-sync.useLegacyPanels',
        ({ newValue }) => {
          this.useLegacyPanels = newValue ? true : !this.workspace.getLeftDock;
        },
        this.rerender()
      )
    );

    this.subscriptions.add(
      atom.commands.add('atom-workspace', {
        'servicenow-sync:toggle': () => this.toggle()
      })
    );
  }
  async activate(state = {}) {
    logger.time('Servicenow Sync activation took');

    this.savedState = { ...defaultState, ...state };
    const firstRun = !await fileExists(this.configPath);
    this.startOpen = firstRun && !this.config.get('welcome.showOnStartup');
    if (firstRun) {
      await writeFile(
        this.configPath,
        '{\n  "__Description": "Store non-visible Servicenow Sync package state."\n}'
      );
    }
    this.activated = true;

    logger.timeEnd('Servicenow Sync activation took');
  }

  rerender(cb) {
    if (this.workspace.isDestroyed() || !this.activated) {
      return;
    }
    if (!this.element) {
      this.element = document.createElement('div');
      this.subscriptions.add(
        new Disposable(() => {
          ReactDom.unmountComponentAtNode(this.element);
          delete this.element;
        })
      );
    }
    ReactDom.render(
      <div><h3>ServicenowSyncPackage is ALIVE!</h3></div>,
      this.element,
      cb
    );
  }

  toggle() {
    logger.log(this);
  }
}
