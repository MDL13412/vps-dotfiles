'use strict';

module.exports = {
  // 不要更改types, 只允许出现这几种
  types: [
    {value: 'feat',         name: 'feat:        新功能 (feature)'},
    {value: 'fix',          name: 'fix:         修复bug'},
    {value: 'docs',         name: 'docs:        文档 (documentation)'},
    {value: 'style',        name: 'style:       格式 (不影响代码运行的变动)'},
    {value: 'refactor',     name: 'refactor:    重构 (即不是新增功能，也不是修改bug的代码变动)'},
    {value: 'test',         name: 'test:        增加测试'},
    {value: 'chore',        name: 'chore:       构建过程或辅助工具的变动'},
  ],

  // 按照项目模块, 自行配置
  scopes: [
    {name: 'core'},
    {name: 'api'},
    {name: 'ansible'},
    {name: 'service'},
    {name: 'dao'},
    {name: 'model'},
    {name: 'sql'},
    {name: 'typo'},
    {name: 'lib'},
    {name: 'middleware'},
    {name: 'cron'},
    {name: 'doc'},
    {name: 'tool'},
    {name: 'config'},
    {name: 'util'},
    {name: 'tools'},
    {name: 'monitor'},
    {name: 'chore'},
  ],

  // 可以根据匹配的类型不同, 显示不一样的scope, 动手实践下!
  /*
  scopeOverrides: {
    fix: [
      {name: 'merge'},
      {name: 'style'},
      {name: 'e2eTest'},
      {name: 'unitTest'}
    ]
  },
  */

  allowCustomScopes: true,
  allowBreakingChanges: ['feat', 'fix']
};
