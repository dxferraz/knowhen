const { after, afterEach, before, beforeEach, describe, it } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
} = require('firebase/firestore');

const SONG = { artist: 'Artista', songName: 'Música', month: '3', year: '1999' };
const CURIOSITY = { fact: 'Nasce o Mercosul', month: '3', year: '1991' };

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-knowhen',
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8'),
    },
  });
});

after(() => env.cleanup());

beforeEach(async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'brasil-songs', '1999-03'), SONG);
    await setDoc(doc(db, 'brasil-curiosities', 'c1'), CURIOSITY);
    await setDoc(doc(db, 'outra-colecao', 'x'), { a: 1 });
  });
});

afterEach(() => env.clearFirestore());

// O app faz signInAnonymously(), então o usuário "comum" é um anônimo.
const anon = () => env.authenticatedContext('anon-uid', { firebase: { sign_in_provider: 'anonymous' } }).firestore();
const guest = () => env.unauthenticatedContext().firestore();

describe('brasil-songs', () => {
  it('permite ler o documento e listar para usuário autenticado', async () => {
    await assertSucceeds(getDoc(doc(anon(), 'brasil-songs', '1999-03')));
    await assertSucceeds(getDocs(collection(anon(), 'brasil-songs')));
  });

  it('nega leitura sem login', async () => {
    await assertFails(getDoc(doc(guest(), 'brasil-songs', '1999-03')));
  });

  it('nega create, update e delete para usuário autenticado', async () => {
    const db = anon();
    await assertFails(setDoc(doc(db, 'brasil-songs', '2000-01'), SONG));
    await assertFails(updateDoc(doc(db, 'brasil-songs', '1999-03'), { artist: 'Outro' }));
    await assertFails(deleteDoc(doc(db, 'brasil-songs', '1999-03')));
  });
});

describe('brasil-curiosities', () => {
  it('permite ler para usuário autenticado e nega sem login', async () => {
    await assertSucceeds(getDoc(doc(anon(), 'brasil-curiosities', 'c1')));
    await assertSucceeds(getDocs(collection(anon(), 'brasil-curiosities')));
    await assertFails(getDoc(doc(guest(), 'brasil-curiosities', 'c1')));
  });

  it('permite gravar o imageUrl (o que o app faz depois de gerar a imagem)', async () => {
    await assertSucceeds(
      updateDoc(doc(anon(), 'brasil-curiosities', 'c1'), {
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/x/o/y.png?alt=media',
      }),
    );
  });

  it('permite trocar um imageUrl que já existia', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'brasil-curiosities', 'c2'), { ...CURIOSITY, imageUrl: 'https://a' }),
    );
    await assertSucceeds(updateDoc(doc(anon(), 'brasil-curiosities', 'c2'), { imageUrl: 'https://b' }));
  });

  it('nega o update do imageUrl sem login', async () => {
    await assertFails(updateDoc(doc(guest(), 'brasil-curiosities', 'c1'), { imageUrl: 'https://a' }));
  });

  it('nega update de outro campo', async () => {
    await assertFails(updateDoc(doc(anon(), 'brasil-curiosities', 'c1'), { fact: 'Pichado' }));
  });

  it('nega update que mistura imageUrl com outro campo', async () => {
    await assertFails(
      updateDoc(doc(anon(), 'brasil-curiosities', 'c1'), { imageUrl: 'https://a', fact: 'Pichado' }),
    );
  });

  it('nega imageUrl que não seja string', async () => {
    const ref = doc(anon(), 'brasil-curiosities', 'c1');
    await assertFails(updateDoc(ref, { imageUrl: 42 }));
    await assertFails(updateDoc(ref, { imageUrl: null }));
    await assertFails(updateDoc(ref, { imageUrl: ['https://a'] }));
  });

  it('nega imageUrl gigante', async () => {
    await assertFails(updateDoc(doc(anon(), 'brasil-curiosities', 'c1'), { imageUrl: 'h'.repeat(2049) }));
  });

  it('nega create e delete', async () => {
    const db = anon();
    await assertFails(setDoc(doc(db, 'brasil-curiosities', 'novo'), CURIOSITY));
    await assertFails(deleteDoc(doc(db, 'brasil-curiosities', 'c1')));
  });
});

describe('qualquer outra coleção', () => {
  it('nega leitura e escrita, mesmo autenticado', async () => {
    const db = anon();
    await assertFails(getDoc(doc(db, 'outra-colecao', 'x')));
    await assertFails(setDoc(doc(db, 'outra-colecao', 'y'), { a: 1 }));
    await assertFails(updateDoc(doc(db, 'outra-colecao', 'x'), { a: 2 }));
    await assertFails(deleteDoc(doc(db, 'outra-colecao', 'x')));
  });
});
