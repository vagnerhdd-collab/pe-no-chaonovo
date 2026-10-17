# Pé no Chão: o sócio cético da sua ideia

Sócio de IA para qualquer pessoa no Brasil que quer abrir ou mudar um negócio. A pessoa conta a ideia e informa a cidade. Ele faz até 8 perguntas difíceis, uma por vez, levando em conta a realidade do lugar. No fim, entrega:
- nota de 0 a 100;
- a conta em números;
- os riscos;
- 3 ações para resolver antes de seguir;
- um teste de 7 dias.

**Preço:** 1 teste grátis. Depois, R$ 9,90 no PIX (30 dias, sem renovação) ou R$ 9,90/mês no cartão (renova sozinho).

**Stack:** Next.js 14 (Vercel), Supabase, API do Claude e Mercado Pago. O WhatsApp é opcional e pode ser ligado depois.

**Custo por teste:** as perguntas usam o modelo rápido (Haiku) e o veredito usa o Sonnet. Fica em torno de R$ 0,10 a R$ 0,30 por teste completo. O limite padrão é de 10 testes por dia por assinante.

---

## Colocar no ar

### 1. Supabase
1. Crie um projeto (região São Paulo).
2. Em **SQL Editor**, rode `supabase/schema.sql`.
3. Em **Authentication > URL Configuration**, configure:
   - **Site URL:** seu domínio.
   - **Redirect URL:** `https://seudominio.com.br/auth/callback`.
4. Traduza o e-mail de Magic Link. Em produção, use um SMTP próprio (Resend ou Brevo).
5. Copie a URL, a `anon key` e a `service_role key`.

### 2. Claude
1. Em console.anthropic.com, crie uma API key.
2. Coloque créditos e defina um teto de gasto mensal.

### 3. Mercado Pago
1. Em Suas integrações, crie uma aplicação e copie o **Access Token de produção**.
2. Em **Webhooks**, cadastre `https://seudominio.com.br/api/mp/webhook` e marque dois eventos:
   - **Pagamentos** (`payment`): libera o passe de 30 dias no PIX.
   - **Planos e assinaturas** (`subscription_preapproval`): libera a assinatura no cartão.
3. Copie a assinatura secreta para `MP_WEBHOOK_SECRET`.
4. Confirme que o PIX está ativo na sua conta (é preciso ter uma chave PIX cadastrada).

### 4. Vercel
1. Suba o projeto para um GitHub privado e importe na Vercel.
2. Cole as variáveis do `.env.example`.
3. Faça o deploy e aponte o domínio.

### 5. Testar antes de divulgar
- Faça login e o teste grátis completo, informando cidade e estado.
- Tente um segundo teste: deve aparecer a tela com as duas formas de pagamento.
- Pague o PIX de R$ 9,90. Confira se `access_until` foi preenchido em Supabase > profiles.
- Assine no cartão, depois cancele, e confira o `plan_status`.
- Coloque seu e-mail em `ADMIN_EMAILS` e abra `/painel` para ver as métricas por estado, setor e nota.

---

## Ajustes rápidos
| O quê | Onde |
|---|---|
| Jeito de falar e regras do sócio | `lib/ai.js` (`BASE`, `ASK`, `VERDICT`) |
| Nomes dos pilares | `lib/labels.js` |
| Preços e dias do passe | `PLAN_PRICE`, `PASS_PRICE`, `PASS_DAYS` |
| Testes grátis e limite diário | `FREE_SESSIONS`, `DAILY_SESSION_CAP` |
| Textos da página inicial | `app/page.js` |

## WhatsApp (opcional, para depois)
O código já está pronto em `app/api/whatsapp` e `lib/waflow.js`. Funciona com texto e áudio.

Para ligar:
1. Preencha as variáveis `WA_*` e `TRANSCRIBE_*`.
2. Cadastre o webhook `https://seudominio.com.br/api/whatsapp` na Meta, no campo `messages`.
3. Preencha `NEXT_PUBLIC_WA_NUMBER` para o botão aparecer no site.

Pelo WhatsApp, o limite padrão é de 2 testes grátis por número a cada 30 dias. Depois disso, a pessoa é convidada a assinar pelo site.

## Antes de lançar
- Pesquise e registre "Pé no Chão" no INPI. É uma expressão comum, então pode haver registros parecidos.
- Preencha CNPJ e contato nos Termos e publique uma Política de Privacidade (LGPD).
