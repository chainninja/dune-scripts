# 🚀 快速参考指南

## 📁 文件夹内容一览

```
币安人生/
├── bsc-holder-category-barchart.sql      ⭐ 柱状图/饼图数据
├── bsc-token-concentration.sql           ⭐⭐ 集中度分析（推荐先运行）
├── bsc-top-holders.sql                   📋 Top 100详细列表
├── bsc-token-holder-growth-simple.sql    📈 增长趋势（快速）
├── bsc-token-holder-growth.sql           📊 增长趋势（详细，较慢）
├── BSC_TOKEN_HOLDER_README.md            📖 完整使用指南
└── QUICK_REFERENCE.md                    ⚡ 本文档
```

---

## ⚡ 3分钟快速开始

### 1️⃣ 第一个查询（1分钟）
```
文件: bsc-token-concentration.sql
作用: 看到所有关键指标
结果: Whale占比、Top 10占比、总holder数等
```

### 2️⃣ 创建第一个图表（1分钟）
```
文件: bsc-holder-category-barchart.sql
操作: Run → + New visualization → Bar Chart
配置: X轴=Category, Y轴=Number of Holders
```

### 3️⃣ 查看Top Holders（1分钟）
```
文件: bsc-top-holders.sql
作用: 看到Top 100具体地址和行为
结果: 排名、地址、余额、holder类型
```

---

## 🎯 我想要...

### 看Whale控制了多少？
→ 运行 `bsc-token-concentration.sql`
→ 查看 "🐋 Whales" 行的百分比

### 创建holder分布图？
→ 运行 `bsc-holder-category-barchart.sql`
→ 新建Bar Chart或Pie Chart

### 查看Top 100是谁？
→ 运行 `bsc-top-holders.sql`
→ 显示为表格

### 看holder增长趋势？
→ 运行 `bsc-token-holder-growth-simple.sql`
→ 创建Line Chart

---

## 📊 推荐的Dashboard组合

```
┌─────────────────────────────────────┐
│  集中度分析表格                      │
│  (bsc-token-concentration.sql)      │
├──────────────────┬──────────────────┤
│  Holder分布柱状图 │  持仓占比饼图     │
│  (barchart.sql)  │  (barchart.sql)  │
├──────────────────┴──────────────────┤
│  Top 100 Holders表格                │
│  (bsc-top-holders.sql)              │
├─────────────────────────────────────┤
│  Holder增长趋势折线图                │
│  (growth-simple.sql)                │
└─────────────────────────────────────┘
```

---

## ⚙️ 重要设置

### 合约地址
```
0x924fa68a0FC644485b8df8AbfA0A41C2e7744444
```

### 代币精度
```
18位 (1e18)
```
⚠️ 如果不是18，需要修改所有查询中的 `1e18`

### 时间范围
```
block_date >= TIMESTAMP '2025-10-02 00:00:00'
```
⚠️ 可以调整这个日期来改变查询范围

---

## 🔥 最常用的3个查询

### 🥇 第一名: `bsc-token-concentration.sql`
- 最直观
- 运行最快
- 信息最全面
- 适合日常监控

### 🥈 第二名: `bsc-holder-category-barchart.sql`
- 适合做图表
- 数据清晰
- 可视化效果好

### 🥉 第三名: `bsc-top-holders.sql`
- 识别大户
- 分析行为
- 监控风险

---

## ⚠️ 常见错误

### "Query timeout"
→ 查询超时了，缩短时间范围

### "Incompatible types"
→ 类型不匹配，确认已使用最新版本的查询

### 结果和BscScan不一样
→ 检查代币精度（Decimals）是否正确

### 查询很慢
→ 使用 `-simple` 版本或缩短时间范围

---

## 💡 Pro Tips

1. **先运行 `bsc-token-concentration.sql`**
   → 快速了解整体情况

2. **保存查询**
   → Dune会缓存结果，下次更快

3. **创建Dashboard**
   → 把多个可视化组合在一起

4. **设置自动刷新**
   → 每天自动更新数据

5. **分享给社区**
   → 公开Dashboard获得反馈

---

## 🆘 求助清单

遇到问题时，检查：
- [ ] 合约地址正确？
- [ ] 代币精度（Decimals）正确？
- [ ] 时间范围是否太大？
- [ ] 是否选择了正确的链（BSC）？
- [ ] SQL语法是否有错误？

---

## 📞 联系方式

有问题？随时告诉我：
1. 把错误信息发给我
2. 说明你想要什么结果
3. 我会帮你调整查询！

---

**记住**: 从简单开始，先运行 `bsc-token-concentration.sql`！✨

