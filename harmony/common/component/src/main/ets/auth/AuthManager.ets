/**
 * 登录态管理器（单例）
 * 对应 Android 端的 AuthManager，使用 preferences 持久化存储 token/username
 */
import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

export class AuthManager {
  private static instance: AuthManager | null = null;
  private prefs: preferences.Preferences | null = null;

  private static readonly PREFS_NAME = 'auth_prefs';
  private static readonly KEY_TOKEN = 'auth_token';
  private static readonly KEY_USERNAME = 'auth_username';

  private constructor() {}

  static getInstance(): AuthManager {
    if (!AuthManager.instance) {
      AuthManager.instance = new AuthManager();
    }
    return AuthManager.instance;
  }

  async init(context: Context): Promise<void> {
    this.prefs = await preferences.getPreferences(context, AuthManager.PREFS_NAME);
  }

  async saveLogin(token: string, username: string): Promise<void> {
    if (!this.prefs) return;
    await this.prefs.put(AuthManager.KEY_TOKEN, token);
    await this.prefs.put(AuthManager.KEY_USERNAME, username);
    await this.prefs.flush();
  }

  getToken(): string {
    if (!this.prefs) return '';
    return this.prefs.getSync(AuthManager.KEY_TOKEN, '') as string;
  }

  getUsername(): string {
    if (!this.prefs) return '';
    return this.prefs.getSync(AuthManager.KEY_USERNAME, '') as string;
  }

  isLoggedIn(): boolean {
    return this.getToken().length > 0;
  }

  async logout(): Promise<void> {
    if (!this.prefs) return;
    await this.prefs.delete(AuthManager.KEY_TOKEN);
    await this.prefs.delete(AuthManager.KEY_USERNAME);
    await this.prefs.flush();
  }
}
