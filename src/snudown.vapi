/*
 * Copyright (C) 2016, Sam Parkinson
 * The following license matches markdown.h from github.com/reddit/snudown
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

[CCode (cheader_filename = "snudown.h", cprefix = "")]
namespace Snudown {
    [CCode (cprefix = "MDKA_", cname = "int", has_type_id = false)]
    public enum AutolinkType {
        NOT_AUTOLINK,
        NORMAL,
        EMAIL
    }

    [Flags]
    [CCode (cprefix = "MKD_TABLE_", cname = "int", has_type_id = false)]
    public enum TableFlags {
        ALIGN_L,
        ALIGN_R,
        ALIGN_CENTER,
        ALIGNMASK,
        HEADER
    }

    [Flags]
    [CCode (cprefix = "MKDEXT_", cname = "int", has_type_id = false)]
    enum Extensions {
        NO_INTRA_EMPHASIS,
        TABLES,
        FENCED_CODE,
        AUTOLINK,
        STRIKETHROUGH,
        SPACE_HEADERS,
        SUPERSCRIPT,
        LAX_SPACING,
        NO_EMAIL_AUTOLINK
    }

    [CCode (cname = "int", has_type_id = false)]
    [Flags]
    public enum ListFlags {
        [CCode (cname = "MKD_LIST_ORDERED")]
        ORDERED,
        [CCode (cname = "MKD_LI_BLOCK")]
        BLOCK
    }

    [CCode (cname = "SDBuf", has_type_id = false)]
    [Compact]
    public class Buffer {
        [CCode (cname = "bufnew")]
        public Buffer (size_t unit);

        [CCode (cname = "bufputs")]
        public void puts (string data);

        [CCode (cname = "bufputc")]
        private void stupid_putc (int data);

        public void putc (char data) {
            this.stupid_putc ((int) data);
        }

        [CCode]
        public size_t unit;
        [CCode]
        public size_t size;
        [CCode (array_length_cname = "size", array_length_type = "size_t")]
	public char[] data;

        public string str () {
            return ((string) this.data).substring (0, (int) this.size);
        }
    }

    namespace CallbackTypes {
        /* blockquote, blockhtml, paragraph, normal_text */
        public static delegate void block (
            Buffer ob, Buffer text, GLib.Object user_data
        );

        public static delegate void blockcode (
            Buffer ob, Buffer text, Buffer lang, GLib.Object user_data
        );

        [CCode]
        public static delegate void enter (
            Buffer ob, GLib.Object user_data
        );

        [CCode]
        public static delegate void header (
            Buffer ob, Buffer text, int level, GLib.Object user_data
        );

        [CCode]
        public static delegate void hrule (
            Buffer ob, GLib.Object user_data
        );

        /* list, listitem */
        [CCode]
        public static delegate void list (
            Buffer ob, Buffer text, ListFlags flags, GLib.Object user_data
        );

        [CCode]
        public static delegate void autolink (
            Buffer ob, Buffer link, AutolinkType type, GLib.Object user_data
        );
        [CCode]
        public static delegate void link (
            Buffer ob, Buffer link, Buffer? title, Buffer content, GLib.Object user_data
        );

        [CCode]
        public static delegate void enter_tableflags (
            Buffer ob, TableFlags tableflags, GLib.Object user_data
        );
        [CCode]
        public static delegate void table (
            Buffer ob, Buffer header, Buffer body, GLib.Object user_data
        );
        [CCode]
        public static delegate void table_cell (
            Buffer ob, Buffer text, TableFlags flags, GLib.Object user_data
        );
    }

    [CCode (cname = "SDCallbacks")]
    struct Callbacks {
        [CCode]
        public CallbackTypes.blockcode? blockcode;
        [CCode]
        public CallbackTypes.block? blockquote;
        [CCode]
        public CallbackTypes.enter? enter_blockquote;
        [CCode]
        public CallbackTypes.block? blockhtml;
        [CCode]
        public CallbackTypes.header? header;
        [CCode]
        public CallbackTypes.hrule? hrule;
        [CCode]
        public CallbackTypes.list? list;
        [CCode]
        public CallbackTypes.enter? enter_list;
        [CCode]
        public CallbackTypes.list? listitem;
        [CCode]
        public CallbackTypes.enter? enter_listitem;
        [CCode]
        public CallbackTypes.block? paragraph;

        [CCode]
        public CallbackTypes.enter? enter_table;
        [CCode]
        public CallbackTypes.enter_tableflags? enter_table_row;
        [CCode]
        public CallbackTypes.enter_tableflags? enter_table_cell;
        [CCode]
        public CallbackTypes.table? table;
        [CCode]
        public CallbackTypes.block? table_row;
        [CCode]
        public CallbackTypes.table_cell? table_cell;

        /* span level callbacks - NULL or return 0 prints the span verbatim */
        [CCode]
        public CallbackTypes.autolink? autolink;
        [CCode]
        public CallbackTypes.link? link;

        [CCode]
        public CallbackTypes.block? emphasis;
        [CCode]
        public CallbackTypes.block? double_emphasis;
        [CCode]
        public CallbackTypes.block? triple_emphasis;
        [CCode]
        public CallbackTypes.block? strikethrough;
        [CCode]
        public CallbackTypes.block? superscript;
        [CCode]
        public CallbackTypes.block? codespan;

        /*int (*image)(struct buf *ob, const struct buf *link, const struct buf *title, const struct buf *alt, void *opaque);
        int (*linebreak)(struct buf *ob, void *opaque);
        int (*raw_html_tag)(struct buf *ob, const struct buf *tag, void *opaque);*/

        [CCode]
        public CallbackTypes.block? entity;
        [CCode]
        public CallbackTypes.block? normal_text;
    }

    [Compact]
    [CCode (cname = "SDMarkdown",
            free_function = "sd_markdown_free",
            has_type_id = false,
            simple_generics = true)]
    class Markdown<T> {
        [CCode (cname = "sd_markdown_new")]
        public Markdown (
            Extensions extentions,
            size_t max_nesting,
            size_t max_table_cols,
            Callbacks callbacks,
            T opaque
        );

        [CCode (cname = "sd_markdown_render_sane")]
        public void render (
            Buffer out_buffer,
            char[] document
        );
    }
}
