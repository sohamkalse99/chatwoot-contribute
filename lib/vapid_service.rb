class VapidService
  def self.public_key
    vapid_keys['public_key']
  end

  def self.private_key
    vapid_keys['private_key']
  end

  def self.vapid_keys
    config = GlobalConfig.get('VAPID_KEYS')
    # Fix: Access the config directly, not config['VAPID_KEYS']
    return config if config.present? && config.is_a?(Hash)

    # keys don't exist in the database. so let's generate and save them
    keys = WebPush.generate_key
    # TODO: remove the logic on environment variables when we completely deprecate
    public_key = ENV.fetch('VAPID_PUBLIC_KEY') { keys.public_key }
    private_key = ENV.fetch('VAPID_PRIVATE_KEY') { keys.private_key }

    vapid_data = { 'public_key' => public_key, 'private_key' => private_key }
    InstallationConfig.where(name: 'VAPID_KEYS').first_or_create(value: vapid_data)
    vapid_data
  end

  private_class_method :vapid_keys
end