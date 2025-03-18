import secrets

from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    """
    Classe que representa a configuração baseada em ambiente da API.
    """

    model_config = SettingsConfigDict(env_file='.env', env_ignore_empty=True, extra='ignore')

    SECRET_KEY: str = secrets.token_urlsafe(32)
    ALGORITHM: str = 'HS256'
    # 60 minutes * 24 hours * 8 days = 8 days
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8
    DEFAULT_TEST_PASSWORD: str = 'faz o L'

    DATABASE_URL: str = 'sqlite://'
    BIG_FILES_DIR: str | None = None

    LOCAL_AWS_SERVER_PUBLIC_KEY: str = 'mock_public_key'
    LOCAL_AWS_SERVER_SECRET_KEY: str = 'mock_secret_key'
    LOCALHOST_ENV: str = 'true'

    MAILGUN_API_KEY: str = 'mailgun_api_key'
    MAILGUN_DOMAIN: str = 'labcomunica.com'
    BASE_URL: str = 'http://localhost:8000'


settings = Settings()