## 1.2.0

- `baseUrl` 和签名参数（`accessKeyId`/`accessKeySecret`）现在完全独立
- 支持 CORS 代理模式：设置 `baseUrl` 的同时仍可传入签名凭证
- 移除 `isProxyMode` getter，新增 `needsSignature` getter
- 构造函数校验：未提供 `baseUrl` 时必须提供签名凭证

## 1.1.0

- 小调整优化修复.

## 1.0.0

- Initial version.
