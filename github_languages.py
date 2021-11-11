#!/bin/python3
# github languages - totals the percentage of language use for a given user
# Copyright (C) 2021 FearlessDoggo21
# see LICENCE file for licensing information

import json, requests


def perc(num: float):
    string = str(round(num, 4))[2:] + '%'
    return string[:2] + '.' + string[2:]


def main(name: str):
    repos, langs, page, total, longest = list(), dict(), 1, 0, 7

    with open("TOKEN.txt", "r") as token_file:
        token = token_file.read()
        if token[-1] == '\n':
            token = token[:-1]

    while True:
        response = requests.get("https://api.github.com/users/"
                f"{name}/repos?per_page=100&page={page}",
                headers={"Authorization": "token " + token})
        response.raise_for_status()
        res_repos = response.json()
        
        if len(res_repos) == 0:
            break

        for res_repo in res_repos:
            repos.append(res_repo["name"])
        page += 1

    for repo in repos:
        res_langs = requests.get("https://api.github.com/repos/"
                f"{name}/{repo}/languages",
                headers={"Authorization": "token " + token}).json()
        
        for res_lang in res_langs:
            if res_lang in langs:
                langs[res_lang] += res_langs[res_lang]
            else:
                langs[res_lang] = res_langs[res_lang]
            
            total += res_langs[res_lang]
            if len(res_lang) > longest:
                longest = len(res_lang)
   
    langs = sorted(langs.items(), key=lambda x: x[1], reverse=True)
    longest_num = len(str(langs[0][1])) # longest num to string for padding
    langs = dict(langs)

    print(f"Total: {total}")
    for lang in langs:
        print(f"{(lang + ':').ljust(longest + 1)} "
                f"{str(langs[lang]).ljust(longest_num)} "
                f"({perc(langs[lang] / total)})")


if __name__ == "__main__":
    main(input("GitHub Username: "))
