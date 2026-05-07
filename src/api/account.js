/**
 * 账号密码管理 - API 接口层
 *
 * 当前使用本地 Mock 数据，后续对接后端只需替换各函数内部的实现即可。
 * 接口规范：
 *   - 所有函数返回 Promise
 *   - 返回格式统一为 { code: 0, data: T, message: string }
 *   - code === 0 表示成功，非 0 表示失败
 */

// ==================== 数据模型 ====================

// Account: { id, title, category, username, password, url, remark, createdAt, updatedAt }

// 分类枚举
export const CATEGORIES = {
  all: { key: 'all', label: '全部' },
  social: { key: 'social', label: '社交' },
  work: { key: 'work', label: '工作' },
  finance: { key: 'finance', label: '金融' },
  other: { key: 'other', label: '其他' },
};

// ==================== Mock 数据 ====================

let mockData = [
  {
    id: '1',
    title: '微信',
    category: 'social',
    username: 'wx_zhaoyudong',
    password: 'Wx@2024secure',
    url: 'https://weixin.qq.com',
    remark: '个人微信号',
    createdAt: '2025-12-01 10:00:00',
    updatedAt: '2025-12-01 10:00:00',
  },
  {
    id: '2',
    title: 'GitHub',
    category: 'work',
    username: 'zhaoyudong',
    password: 'Gh#Dev2024!',
    url: 'https://github.com',
    remark: '工作账号',
    createdAt: '2025-12-05 14:30:00',
    updatedAt: '2025-12-05 14:30:00',
  },
  {
    id: '3',
    title: '支付宝',
    category: 'finance',
    username: '138****8888',
    password: 'Alipay$2024',
    url: 'https://www.alipay.com',
    remark: '',
    createdAt: '2025-12-10 09:15:00',
    updatedAt: '2025-12-10 09:15:00',
  },
  {
    id: '4',
    title: '掘金',
    category: 'work',
    username: 'dev_zhaoyd',
    password: 'Jj@2024blog',
    url: 'https://juejin.cn',
    remark: '技术博客账号',
    createdAt: '2025-12-15 16:00:00',
    updatedAt: '2025-12-15 16:00:00',
  },
  {
    id: '5',
    title: '网易云音乐',
    category: 'other',
    username: 'music_lover@qq.com',
    password: 'Music#163',
    url: 'https://music.163.com',
    remark: '',
    createdAt: '2026-01-02 11:20:00',
    updatedAt: '2026-01-02 11:20:00',
  },
];

let nextId = 6;

// ==================== 工具函数 ====================

const delay = (ms = 300) => new Promise(resolve => setTimeout(resolve, ms));

const now = () => {
  const d = new Date();
  const pad = n => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
};

// ==================== 接口实现 ====================

/**
 * 获取账号列表
 * GET /api/accounts
 * @param {Object} params - { keyword?: string, category?: string }
 * @returns {Promise<{ code: number, data: Account[] }>}
 */
export async function getAccountList(params = {}) {
  await delay();
  let list = [...mockData];

  if (params.category && params.category !== 'all') {
    list = list.filter(item => item.category === params.category);
  }

  if (params.keyword) {
    const kw = params.keyword.toLowerCase();
    list = list.filter(
      item =>
        item.title.toLowerCase().includes(kw) ||
        item.username.toLowerCase().includes(kw),
    );
  }

  return { code: 0, data: list };
}

/**
 * 获取账号详情
 * GET /api/accounts/:id
 * @param {string} id
 * @returns {Promise<{ code: number, data: Account }>}
 */
export async function getAccountDetail(id) {
  await delay();
  const item = mockData.find(a => a.id === id);
  if (!item) {
    return { code: -1, data: null, message: '账号不存在' };
  }
  return { code: 0, data: { ...item } };
}

/**
 * 新增账号
 * POST /api/accounts
 * @param {Object} data - { title, username, password, url?, remark?, category? }
 * @returns {Promise<{ code: number, data: Account }>}
 */
export async function createAccount(data) {
  await delay();
  const timestamp = now();
  const account = {
    id: String(nextId++),
    title: data.title || '',
    category: data.category || 'other',
    username: data.username || '',
    password: data.password || '',
    url: data.url || '',
    remark: data.remark || '',
    createdAt: timestamp,
    updatedAt: timestamp,
  };
  mockData.unshift(account);
  return { code: 0, data: { ...account } };
}

/**
 * 更新账号
 * PUT /api/accounts/:id
 * @param {string} id
 * @param {Object} data - 同 createAccount 参数
 * @returns {Promise<{ code: number, data: Account }>}
 */
export async function updateAccount(id, data) {
  await delay();
  const index = mockData.findIndex(a => a.id === id);
  if (index === -1) {
    return { code: -1, data: null, message: '账号不存在' };
  }
  const updated = {
    ...mockData[index],
    title: data.title ?? mockData[index].title,
    category: data.category ?? mockData[index].category,
    username: data.username ?? mockData[index].username,
    password: data.password ?? mockData[index].password,
    url: data.url ?? mockData[index].url,
    remark: data.remark ?? mockData[index].remark,
    updatedAt: now(),
  };
  mockData[index] = updated;
  return { code: 0, data: { ...updated } };
}

/**
 * 删除账号
 * DELETE /api/accounts/:id
 * @param {string} id
 * @returns {Promise<{ code: number, data: null }>}
 */
export async function deleteAccount(id) {
  await delay();
  const index = mockData.findIndex(a => a.id === id);
  if (index === -1) {
    return { code: -1, data: null, message: '账号不存在' };
  }
  mockData.splice(index, 1);
  return { code: 0, data: null };
}
