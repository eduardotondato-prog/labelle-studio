# La Belle — implementação de variantes P/M/G

## Situação
Pacote técnico de implementação; não aplicado ao GitHub nem ao Railway.

## Contrato
- `service_variants` guarda `service_id`, `size` (`P`, `M`, `G`), `price`, `duration_minutes`, `commission_percent`, `is_active`.
- Serviços sem variantes (cortes e categorias não cabelo) continuam usando `services.price` e `services.duration_minutes`.
- No catálogo, mostrar uma única ficha por serviço e o menor preço ativo como 'A partir de'.
- No agendamento, exigir variante para serviços que tenham variantes; consultar disponibilidade usando duração da variante.
- A API deve calcular preço e duração da variante no servidor; nunca aceitar preço arbitrário do navegador.
- A administração é a única autorizada a cadastrar/editar/desativar variantes.
- Preservar preço e duração do agendamento no momento da reserva (snapshot) para que mudanças posteriores não alterem reservas antigas.
- Validar que a variante pertence ao serviço, está ativa, e o serviço está ativo.
- A promoção deve ser aplicada ao preço da variante selecionada.
- Migração de dados deve ser revisada e aplicada apenas após backup; não duplicar serviços já cadastrados.

## Arquivos
- `migration.sql`: estrutura PostgreSQL (requer integração com migrações Ecto/Ash).
- `variantes.csv`: tabela inicial de preços propostos (não aplicar sem aprovação).

## Pontos de alteração no repositório
1. Backend `LabelleBack.Studio.ServiceVariant`: recurso Ash com políticas públicas de leitura e escrita somente admin; expor em `Studio` e AshJsonApiRouter.
2. Backend `Appointment`: adicionar `service_variant_id` à criação manual e à action pública `book_online`; manter nullable para serviços sem variante.
3. `SnapshotAppointmentFields`: usar preço/duração da variante selecionada, com validação de vínculo e atividade.
4. `ApplyActivePromotion`: calcular desconto sobre o valor selecionado, não sobre o preço-base.
5. Front `src/server/api.ts`: expor `ServiceVariantsApi` com lista/criação/atualização; propagar `service_variant_id` no agendamento.
6. Front `src/pages/Services.jsx`: editor de variantes por serviço, disponível apenas para admin.
7. Front `src/components/client-app/ClientBooking.jsx`: exigir escolha P/M/G, calcular horários com duração da variante e enviar `service_variant_id`.
8. Front `src/components/client-app/ClientCatalog.jsx`: mostrar um card por serviço, preço inicial e variantes no detalhe.
9. Testes: preço forjado, variante de outro serviço, inativa, concorrência de horários, promoções, alteração de preços após reserva, comissões.

## Atenção
Não é seguro simplesmente passar `price` do frontend para `book_online`: o código atual deliberadamente impede isso. Sem a alteração no backend, a cliente verá um preço mas a reserva será gravada com o preço-base.
