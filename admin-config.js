/* ============================================================================
   PAINEL ADMINISTRATIVO — conexão com o Supabase
   ----------------------------------------------------------------------------
   Preencha as duas linhas abaixo com os dados do seu projeto
   (Supabase > Project Settings > API):

     supabaseUrl      = "Project URL"      ex: https://abcdefgh.supabase.co
     supabaseAnonKey  = "anon public"      (a chave longa que começa com eyJ...)

   A chave "anon public" pode ficar no repositório: ela só dá acesso ao que as
   políticas de RLS liberam. NUNCA coloque aqui a chave "service_role".
   ========================================================================== */
window.ADMIN_CONFIG = {
  supabaseUrl: '',
  supabaseAnonKey: '',
  bucket: 'midia'
};
