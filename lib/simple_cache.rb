require 'active_support/core_ext/integer/time'

class SimpleCache

  # Verifica se o arquivo existe e é recente (última alteração foi no dia de
  # hoje). Em caso afirmativo, lê dados do arquivo (via Marshal.load); caso
  # contrário, executa bloco para regerar os dados, salva no arquivo (via
  # Marshal.dump) e retorna os dados atualizados.
  def self.load_or_recompute(cache_file_name, &block)
    cache_file_pathname = 'tmp/cache/' + cache_file_name

    # TODO: recriar arquivo de cache se fonte dos dados for mais recente?

    if File.exists?(cache_file_pathname) && (File.mtime(cache_file_pathname) > Date.today.beginning_of_day && !Rails.env.production?)
      puts "Arquivo '#{cache_file_name}' já existe e é recente. Utilizando cópia em cache."
      cache_file_contents = File.binread(cache_file_pathname)
      return Marshal.load(cache_file_contents)
    else
      puts "Arquivo '#{cache_file_name}' inexistente ou desatualizado. Gerando novo arquivo de cache."
      data_to_cache = block.call
      File.binwrite(cache_file_pathname, Marshal.dump(data_to_cache))
      return data_to_cache
    end
  end

end
