#!/usr/bin/python3

import json
import logging
from argparse import ArgumentParser
from netrc import netrc
from os import path as osp
from tempfile import NamedTemporaryFile

import requests
from gnupg import GPG

DEFAULT_HOST = "release-monitoring.org"

CRATES_ECOSYSTEM = "crates.io"
CRATES_BACKEND = "crates.io"


def get_token(fname, host):
    """Read token for the specified host from a gpg-encrypted netrc file
    The token should be obtained from https://release-monitoring.org/settings/
    """
    path = osp.expanduser(fname)
    with open(path, "rb") as enc, NamedTemporaryFile("w+") as dec:
        GPG().decrypt_file(enc, output=dec.name)
        data = netrc(dec.name)
        _, _, password = data.hosts[host]
        return password


def get_session(token):
    """Create and cofnigure requests.Session"""
    sess = requests.Session()
    sess.headers.update({"Authorization": f"token {token}"})
    return sess


def find_project(sess, host, name, ecosystem=None, homepage=None):
    """Find anitya project(s) with the specified name and ecosystem or homepage
    https://release-monitoring.org/static/docs/api.html#post--api-v2-projects-
    """
    params = {"name": name}
    if ecosystem is not None:
        params["ecosystem"] = ecosystem

    resp = sess.get(f"https://{host}/api/v2/projects", params=params)
    j = resp.json()
    logging.debug(j)
    for item in j["items"]:
        if homepage and item["homepage"] != homepage:
            continue
        return item


def cmd_info_args(subparsers):
    """Create arguments parser for `info` command"""
    parser = subparsers.add_parser("info", help="Get info for the project")
    parser.add_argument("--ecosystem", help="Project ecosystem")
    parser.add_argument(
        "--url",
        help="Project homepage (to distinguish multiple projects with the same name)",
    )
    parser.add_argument("name")
    return parser


def cmd_info(sess, args):
    """`info` command implementation"""
    proj = find_project(
        sess, args.host, args.name, ecosystem=args.ecosystem, homepage=args.url
    )
    print(json.dumps(proj, indent=4))


def cmd_create_crate_args(subparsers):
    """Create project for crate {name}"""
    parser = subparsers.add_parser(
        "create-crate", help="Create project for a rust crate"
    )
    parser.add_argument("name")
    return parser


def cmd_create_crate(sess, args):
    """`create-crate` command implementation"""
    proj = find_project(sess, args.host, args.name, ecosystem=CRATES_ECOSYSTEM)
    if proj is not None:
        logging.error("Crate %s is already registered on %s", args.name, args.host)
    params = {
        "backend": CRATES_BACKEND,
        "check_release": False,
        "homepage": f"https://crates.io/crate/{args.name}",
        "name": args.name,
    }
    resp = sess.post(f"https://{args.host}/api/v2/projects/", json=params)
    logging.info("Status: %s", resp.status_code)
    logging.debug(resp.json())
    if resp.status_code < 200 or resp.status_code >= 300:
        raise Exception("Failed to create project")

    proj = resp.json()
    params = {
        "dry_run": False,
        "id": proj["id"],
        "version_filter": "alpha;beta;rc;pr",
        "version_scheme": "Semantic",
    }
    resp = sess.post(f"https://{args.host}/api/v2/versions/", json=params)
    logging.info("Status: %s", resp.status_code)
    logging.debug(resp.json())


def cmd_update_args(subparsers):
    """Create arguments parser for `update` command"""
    parser = subparsers.add_parser("update", help="Trigger check for a new versions")
    parser.add_argument("--apply", action="store_true", help="Save changes on server")
    parser.add_argument("--ecosystem", help="Project ecosystem")
    parser.add_argument(
        "--url",
        help="Project homepage (to distinguish multiple projects with the same name)",
    )
    parser.add_argument("name")
    return parser


def cmd_update(sess, args):
    """`update` command implementation"""
    proj = find_project(
        sess, args.host, args.name, ecosystem=args.ecosystem, homepage=args.url
    )
    if proj is not None:
        # https://release-monitoring.org/static/docs/api.html#post--api-v2-versions-
        logging.info(
            "Updating %s - %s; dry run: %s",
            args.name,
            proj["homepage"],
            not args.apply,
        )
        payload = {b"id": proj["id"], b"dry_run": not args.apply}
        resp = sess.post(f"https://{args.host}/api/v2/versions/", json=payload)
        logging.info("Status: %s", resp.status_code)
        logging.debug(resp.json())


def init_argparse():
    """Create and configure ArgumentsParser"""
    parser = ArgumentParser()
    parser.add_argument("--verbose", "-v", action="count", default=0)
    parser.add_argument("--host", help="Anitya instance hostname", default=DEFAULT_HOST)
    parser.add_argument(
        "--netrc", default="~/.netrc.gpg", help="Encrypted netrc.gpg location"
    )
    subparsers = parser.add_subparsers(
        title="commands", description="valid commands", dest="command"
    )
    cmd_info_args(subparsers)
    cmd_create_crate_args(subparsers)
    cmd_update_args(subparsers)
    return parser


def main():
    """Program entrypoint"""
    parser = init_argparse()
    args = parser.parse_args()
    logging.basicConfig(level=max(10, logging.WARNING - args.verbose * 10))
    logging.info(args)

    token = get_token(args.netrc, args.host)
    with get_session(token) as session:
        if args.command == "info":
            cmd_info(session, args)
        elif args.command == "create-crate":
            cmd_create_crate(session, args)
        elif args.command == "update":
            cmd_update(session, args)


if __name__ == "__main__":
    main()
