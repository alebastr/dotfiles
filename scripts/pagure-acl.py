#!/usr/bin/python3

import logging
from argparse import Action, ArgumentParser
from enum import Enum
from itertools import chain
from netrc import netrc
from os import path as osp
from string import Template
from tempfile import NamedTemporaryFile

import requests
from gnupg import GPG

DEFAULT_HOST = "src.fedoraproject.org"
API_TEMPLATE = Template("https://$host/api/0/$project$request")
API_ROOT = f"https://{DEFAULT_HOST}/api/0/"


class AccessLevels(Enum):
    OWNER = "owner"
    ADMIN = "admin"
    COMMIT = "commit"
    TICKET = "ticket"


class ProjectAction(Action):

    def __call__(self, parser, namespace, values, option_string=None):
        if values.find("/") == -1:
            values = "rpms/" + values
        setattr(namespace, "project", values)


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


def is_group(name):
    return name[0] == "@"


def as_group(name):
    return "@" + name if name[0] != "@" else name


def print_acl(acls):
    """Dump access control list"""
    users = acls.get("access_users", {})
    groups = acls.get("access_groups", {})
    for level in ["owner", "admin", "commit", "ticket"]:
        values = list(
            chain(map(as_group, groups.get(level, [])), users.get(level, [])))
        if len(values) > 0:
            print(f"{level}: {', '.join(values)}")


def cmd_list_args(subparsers):
    """Create arguments parser for `list` command"""
    parser = subparsers.add_parser("list",
                                   help="List current ACL for the project")
    parser.add_argument("project", action=ProjectAction)
    return parser


def cmd_list(sess, args):
    """`list` command implementation"""
    resp = sess.get(
        API_TEMPLATE.substitute(host=args.host,
                                project=args.project,
                                request=""))

    logging.info("Request status: %s", resp.status_code)
    logging.debug(resp.json())
    resp.raise_for_status()
    print_acl(resp.json())


def cmd_modify_args(subparsers):
    """Create arguments parser for `modify` command"""
    parser = subparsers.add_parser(
        "modify", help="Modify the user or @group access to the project")
    parser.add_argument("project", action=ProjectAction)
    parser.add_argument("name", help="user or @group")
    parser.add_argument(
        "--level",
        choices=["admin", "commit", "ticket", "none"],
        default="commit",
        help="access level",
    )
    return parser


def cmd_modify(sess, args):
    """`modify` command implementation"""
    if args.level not in ("admin", "commit", "ticket", "none"):
        raise Exception(f"Invalid access level '{args.level}'")
    if args.level == "none":
        args.level = ""
    params = {
        "user_type": "group" if is_group(args.name) else "user",
        "name": args.name.lstrip("@"),
        "acl": args.level,
    }

    resp = sess.post(
        API_TEMPLATE.substitute(host=args.host,
                                project=args.project,
                                request="/git/modifyacls"),
        data=params,
    )
    logging.info("Request status: %s", resp.status_code)
    logging.debug(resp.json())
    resp.raise_for_status()
    print_acl(resp.json())


def init_argparse():
    """Create and configure ArgumentsParser"""
    parser = ArgumentParser()
    parser.add_argument("--verbose", "-v", action="count", default=0)
    parser.add_argument("--host",
                        help="Pagure instance hostname",
                        default=DEFAULT_HOST)
    parser.add_argument("--netrc",
                        default="~/.netrc.gpg",
                        help="Encrypted netrc.gpg location")
    subparsers = parser.add_subparsers(title="commands",
                                       description="valid commands",
                                       dest="command")
    cmd_list_args(subparsers)
    cmd_modify_args(subparsers)
    return parser


def main():
    """Program entrypoint"""
    parser = init_argparse()
    args = parser.parse_args()
    logging.basicConfig(level=max(10, logging.WARNING - args.verbose * 10))
    logging.info(args)

    token = get_token(args.netrc, args.host)
    with get_session(token) as session:
        if args.command == "list":
            cmd_list(session, args)
        elif args.command == "modify":
            cmd_modify(session, args)


if __name__ == "__main__":
    main()
