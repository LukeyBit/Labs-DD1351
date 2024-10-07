# Lab 1
Labb i logikprogrammering, del av D1351 Logik för dataloger 2024.

## Uppgift 1 - Unifiering

Betrakta denna fråga till ett Prologsystem:

```Prolog
?- T=f(a,Y,Z), T=f(X,X,b).
```

Vilka bindningar presenteras som resultat?

Ge en kortfattad förklaring till ditt svar!

### Lösning

Då T binds till `f(a,Y,Z)` och sedan till `f(X,X,b)` så måste `f(a,Y,Z)` unifieras med `f(X,X,b)`. Detta leder till att `X = a` eftersom `a` är en individkonstant och inte en variabel. Då `X = a` så måste `Y = a` och `Z = b`. Därmed är svaret att `X = a`, `Y = a` och `Z = b`.

Utmatningen från Prologsystemet blir:

```Prolog
T = f(a, a, b),
X = a,
Y = a,
Z = b.
```

## Uppgift 2 - Representation

En lista är en representation av sekvenser där 
den tomma sekvensen representeras av symbolen `[]`
och en sekvens bestående av tre heltal 1 2 3 
representeras av `[1,2,3]` eller i kanonisk syntax 
```Prolog
'.'(1,'.'(2,'.'(3,[])))
```

Den exakta definitionen av en lista är:

```Prolog
list([]).
list([H|T]) :- list(T).
```


Vi vill definiera ett  predikat som givet en lista som 
representerar en sekvens skapar en annan lista som innehåller
alla element som förekommer i inlistan i samma ordning, men 
om ett element har fōrekommit tidigare i listan skall det 
inte vara med i den resulterande listan.

Till exempel: 
```Prolog
?- remove_duplicates([1,2,3,2,4,1,3,4], E).
```

skall generera `E=[1,2,3,4]`

Definiera alltså predikatet remove_duplicates/2!
Förklara varför man kan kalla detta predikat för en funktion!

### Lösning

```Prolog
remove_duplicates([], []).
remove_duplicates([H|T], [H|R]) :-
    remove_duplicates(T, R),
    not(member(H, R)).
remove_duplicates([H|T], R) :-
    remove_duplicates(T, R),
    member(H, R).
```
Detta predikat kan kallas för en funktion eftersom den är helt och hållet "ren" och funktionell då den ej har några sidoeffekter och är deterministisk, alltså att samma indata alltid ger samma utdata. `remove_duplicates/2` beskriver alltså inte bara en relation mellan två listor utan transformerar data från en lista till en annan.
