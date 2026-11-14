/* =======================================================================
   MONTE SEU FILME — configuração de preços e serviços
   -----------------------------------------------------------------------
   Este arquivo é a única fonte de verdade do configurador.
   Edite os valores aqui (ou use admin-monte-seu-filme.html e substitua
   este arquivo pelo gerado) e o site recalcula tudo sozinho.
   ======================================================================= */
window.MSF_CONFIG = {
  versao: 1,
  marca: {
    nome: 'Pauleanderson | Dr. Filmes',
    assinatura: 'Cineasta Patrimonial',
    whatsapp: '5592999870427',
    whatsappExibicao: '(92) 99987-0427',
    site: 'https://pauleanderson-dr-filmes.netlify.app',
    avisoTecnico: 'Disponibilidade e valor sujeitos à confirmação da equipe.'
  },

  /* Desconto promocional em % aplicado sobre o total (0 = sem desconto) */
  desconto: { percentual: 0, rotulo: 'Condição especial de lançamento' },

  pagamento: 'Sinal de 30% na reserva e o restante em até 2x até a entrega do filme.',

  /* Etapa 1 — tipo de evento (base do orçamento)
     Base = preço de FILMAGEM publicado nas páginas de nicho (R$ 1.797).
     A tabela atual cobra o mesmo valor de vídeo em todos os nichos; a
     diferenciação vem da duração, do estilo e dos adicionais. */
  eventos: [
    { id: 'casamento',   nome: 'Casamento',             base: 1797, ativo: true, icone: 'alianca',    desc: 'Cerimônia, festa e tudo o que acontece entre elas.' },
    { id: 'quinze',      nome: 'Festa de 15 anos',      base: 1797, ativo: true, icone: 'quinze',     desc: 'A entrada, a valsa e a festa da debutante.' },
    { id: 'infantil',    nome: 'Aniversário infantil',  base: 1797,  ativo: true, icone: 'bolo',       desc: 'Festa de criança, com o olhar na família.' },
    { id: 'adulto',      nome: 'Aniversário adulto',    base: 1797, ativo: true, icone: 'brinde',     desc: 'Bodas, 40, 50, 60 anos e celebrações íntimas.' },
    { id: 'formatura',   nome: 'Formatura',             base: 1797, ativo: true, icone: 'capelo',     desc: 'Colação, jantar e a festa da turma.' },
    { id: 'corporativo', nome: 'Evento corporativo',    base: 1797, ativo: true, icone: 'predio',     desc: 'Confraternização, lançamento, convenção.' },
    { id: 'ensaio',      nome: 'Ensaio especial',       base: 1797,  ativo: true, icone: 'camera',     desc: 'Pré-wedding, gestante, família, marca pessoal.' },
    { id: 'outro',       nome: 'Outro evento',          base: 1797, ativo: true, icone: 'calendario', desc: 'Batizado, chá, celebração particular.' }
  ],

  /* Etapa 2 — duração do filme final (acréscimo sobre a base).
     A duração do vídeo NÃO é a quantidade de horas de filmagem. */
  duracoes: [
    { id: 'curto',      nome: 'Filme Curto',      faixa: '1 a 3 minutos',   preco: 0,    ativo: true, destaque: false,
      desc: 'Um vídeo rápido e emocionante, com os melhores momentos do evento. Ideal para compartilhar nas redes sociais.' },
    { id: 'essencial',  nome: 'Filme Essencial',  faixa: '5 a 7 minutos',   preco: 400,  ativo: true, destaque: true,
      desc: 'Uma seleção dos principais momentos, organizada para contar a história do evento.' },
    { id: 'especial',   nome: 'Filme Especial',   faixa: '8 a 12 minutos',  preco: 1200, ativo: true, destaque: false,
      desc: 'Uma história mais completa, com momentos importantes, emoções e detalhes.' },
    { id: 'completo',   nome: 'Filme Completo',   faixa: '15 a 20 minutos', preco: 2200, ativo: true, destaque: false,
      desc: 'Mais momentos registrados, permitindo reviver diferentes partes da celebração.' },
    { id: 'documental', nome: 'Filme Documental', faixa: '25 a 45 minutos', preco: 3800, ativo: true, destaque: false,
      desc: 'Uma recordação extensa, com acontecimentos, falas, homenagens e momentos especiais.' }
  ],

  /* Etapa 3 — estilo de edição */
  estilos: [
    { id: 'simples', nome: 'Edição Simples', preco: 0, ativo: true,
      desc: 'Os melhores momentos do seu evento, organizados em um vídeo bonito, com música e transições suaves.',
      inclui: 'Seleção de cenas, montagem e trilha sonora.',
      exemploYouTube: 'IDsbhTaJNIg' },
    { id: 'cinematografica', nome: 'Edição Cinematográfica', preco: 600, ativo: true,
      desc: 'Seu evento contado como um filme, com uma montagem emocionante, imagens marcantes e música acompanhando cada momento.',
      inclui: 'Montagem narrativa, ritmo musical, tratamento visual e maior atenção aos detalhes.',
      exemploYouTube: 'OEUJ3fe3-_8' },
    { id: 'documental', nome: 'Edição Documental', preco: 900, ativo: true,
      desc: 'Uma história mais verdadeira e completa, preservando falas, acontecimentos e emoções do jeito que aconteceram.',
      inclui: 'Narrativa cronológica ou temática, momentos espontâneos, falas e sons reais do evento.',
      exemploYouTube: 'HG2aAqjltCQ' }
  ],

  /* Etapa 4 — serviços adicionais
     sobConsulta: mostra o aviso de que depende de avaliação da equipe
     conflita: ids que ficam indisponíveis quando este item é marcado  */
  extras: [
    { id: 'preparativos', grupo: 'antes', nome: 'Gravação dos preparativos', desc: 'Cabelo, maquiagem, vestido, os últimos minutos antes.', preco: 350, ativo: true, sobConsulta: false, conflita: [] },
    { id: 'entrevista-familiares', grupo: 'antes', nome: 'Entrevista com familiares', desc: 'Depoimentos gravados antes da festa, com calma.', preco: 400, ativo: true, sobConsulta: false, conflita: [] },
    { id: 'depoimentos', grupo: 'antes', nome: 'Depoimentos especiais', desc: 'Pessoas importantes contam o que aquele dia significa.', preco: 400, ativo: true, sobConsulta: false, conflita: [] },
    { id: 'mensagem-surpresa', grupo: 'antes', nome: 'Mensagem surpresa', desc: 'Uma mensagem gravada em segredo, exibida no evento.', preco: 300, ativo: true, sobConsulta: false, conflita: [] },
    { id: 'ensaio-previo', grupo: 'antes', nome: 'Ensaio em vídeo antes do evento', desc: 'Um encontro de câmera para vocês se acostumarem com o registro.', preco: 550, ativo: true, sobConsulta: false, conflita: [] },
    { id: 'local-especial', grupo: 'antes', nome: 'Gravação em local especial', desc: 'Uma locação escolhida por vocês para abrir o filme.', preco: 450, ativo: true, sobConsulta: false, conflita: [] },

    { id: 'camera-extra', grupo: 'durante', nome: 'Câmera adicional', desc: 'Dois olhares ao mesmo tempo: um no palco, outro na plateia.', preco: 380, ativo: true, sobConsulta: false, conflita: [] },
    { id: 'drone', grupo: 'durante', nome: 'Imagens aéreas com drone', desc: 'Abertura e planos do espaço vistos de cima.', preco: 650, ativo: true, sobConsulta: true, conflita: [] },
    { id: 'cerimonia-completa', grupo: 'durante', nome: 'Gravação completa da cerimônia', desc: 'A cerimônia inteira, do início ao fim, sem cortes.', preco: 450, ativo: true, sobConsulta: false, conflita: [] },
    { id: 'homenagens', grupo: 'durante', nome: 'Homenagens e discursos', desc: 'Quem subir para falar fica registrado com áudio limpo.', preco: 300, ativo: true, sobConsulta: false, conflita: [] },
    { id: 'entrevistas-convidados', grupo: 'durante', nome: 'Entrevistas com convidados', desc: 'Recados rápidos de quem estava lá.', preco: 350, ativo: true, sobConsulta: false, conflita: [] },
    { id: 'horas-adicionais', grupo: 'durante', nome: 'Horas adicionais de cobertura', desc: 'Para quando a festa não quer terminar.', preco: 250, ativo: true, sobConsulta: true, conflita: [] },

    { id: 'reels', grupo: 'depois', nome: 'Vídeo curto para Instagram', desc: 'Um corte de até 60s pronto para publicar no dia seguinte.', preco: 350, ativo: true, sobConsulta: false, conflita: ['vertical'] },
    { id: 'teaser', grupo: 'depois', nome: 'Teaser de até 60 segundos', desc: 'Uma prévia com o melhor do filme, para matar a saudade.', preco: 450, ativo: true, sobConsulta: false, conflita: [] },
    { id: 'vertical', grupo: 'depois', nome: 'Vídeo vertical para Reels e Stories', desc: 'O mesmo filme em formato de celular.', preco: 300, ativo: true, sobConsulta: false, conflita: ['reels'] },
    { id: 'horizontal', grupo: 'depois', nome: 'Versão horizontal para YouTube ou TV', desc: 'Para assistir na sala, com a família reunida.', preco: 250, ativo: true, sobConsulta: false, conflita: [] },
    { id: 'expressa', grupo: 'depois', nome: 'Entrega expressa', desc: 'Prioridade na fila de edição, conforme a agenda.', preco: 400, ativo: true, sobConsulta: true, conflita: [] },
    { id: 'video-extra', grupo: 'depois', nome: 'Vídeo extra com momentos selecionados', desc: 'Um segundo filme, com o recorte que vocês escolherem.', preco: 500, ativo: true, sobConsulta: false, conflita: [] }
  ],

  /* Etapa 5 — entrega (a entrega digital padrão é sempre incluída) */
  entregas: [
    { id: 'link',      nome: 'Link privado para assistir e baixar', desc: 'Galeria fechada, só quem você convidar entra.', preco: 0, ativo: true, incluido: true },
    { id: 'alta',      nome: 'Arquivos digitais em alta qualidade', desc: 'O filme no melhor formato, sem compressão.', preco: 0, ativo: true, incluido: true },
    { id: 'redes',     nome: 'Versão preparada para redes sociais', desc: 'Arquivo leve, do jeito que o Instagram gosta.', preco: 0, ativo: true, incluido: true },
    { id: 'duplo',     nome: 'Versões horizontal e vertical', desc: 'Os dois formatos, sem precisar pedir depois.', preco: 0, ativo: true, incluido: true },
    { id: 'pendrive',  nome: 'Pendrive personalizado em madeira', desc: 'Para guardar fora da nuvem e entregar de presente.', preco: 220, ativo: true, incluido: false }
  ]
};
