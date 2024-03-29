/* $Id: renderprocs.h,v 1.40 2005/07/28 13:08:34 ellson Exp $ $Revision: 1.40 $ */
/* vim:set shiftwidth=4 ts=8: */

/**********************************************************
*      This software is part of the graphviz package      *
*                http://www.graphviz.org/                 *
*                                                         *
*            Copyright (c) 1994-2004 AT&T Corp.           *
*                and is licensed under the                *
*            Common Public License, Version 1.0           *
*                      by AT&T Corp.                      *
*                                                         *
*        Information and Software Systems Research        *
*              AT&T Research, Florham Park NJ             *
**********************************************************/

#ifndef GV_RENDERPROCS_H
#define GV_RENDERPROCS_H

#ifdef __cplusplus
extern "C" {
#endif

    typedef void (*nodesizefn_t) (Agnode_t *, boolean);

    extern void add_box(path *, box);
    extern void arrow_flags(Agedge_t * e, int *sflag, int *eflag);
    extern boxf arrow_bb(pointf p, pointf u, double scale, int flag);
    extern void arrow_gen(GVJ_t * job, point p, point u, double scale,
			  int flag);
    extern double arrow_length(edge_t * e, int flag);
    extern int arrowEndClip(edge_t*, point*, int, int , bezier*, int eflag);
    extern int arrowStartClip(edge_t*, point* ps, int, int, bezier*, int sflag);
    extern void attach_attrs(Agraph_t *);
    extern void beginpath(path *, Agedge_t *, int, pathend_t *, boolean);
    extern void bezier_clip(inside_t * inside_context,
			    boolean(*insidefn) (inside_t * inside_context,
						pointf p), pointf * sp,
			    boolean left_inside);
    extern shape_desc *bind_shape(char *name, node_t *);
    extern void clip_and_install(edge_t *, edge_t *, point *, int,
				 splineInfo *);
    extern char *canontoken(char *str);
    extern char* charsetToStr (int c);
    extern void colorxlate(char *str, color_t * color,
			   color_type_t target_type);
    extern point coord(node_t * n);
    extern void do_graph_label(graph_t * sg);
    extern void graph_init(graph_t * g, boolean use_rankdir);
    extern void graph_cleanup(graph_t * g);
    extern void dotneato_args_initialize(GVC_t * gvc, int, char **);
    extern void dotneato_usage(int);
    extern void dotneato_postprocess(Agraph_t *, nodesizefn_t);
    extern void dotneato_set_margins(GVC_t * gvc, Agraph_t *);
    extern void dotneato_write(GVC_t * gvc, graph_t *g);
    extern void dotneato_write_one(GVC_t * gvc, graph_t *g);
    extern double elapsed_sec(void);
    extern void emit_background(GVJ_t * job, graph_t *g);
    extern void emit_clusters(GVJ_t * job, Agraph_t * g, int flags);
    extern void emit_edge_graphics(GVJ_t * job, edge_t * e);
    extern void emit_graph(GVJ_t * job, graph_t * g);
    extern void emit_label(GVJ_t * job, textlabel_t *, void *obj);
    extern int emit_once(char *message);
    extern void emit_jobs_eof(GVC_t * gvc);
    extern void emit_textlines(GVJ_t*, int, textline_t*, pointf,
              double, char*, double, char*);
    extern void enqueue_neighbors(nodequeue *, Agnode_t *, int);
    extern void endpath(path *, Agedge_t *, int, pathend_t *, boolean);
    extern void epsf_init(node_t * n);
    extern void epsf_free(node_t * n);
    extern void extend_attrs(GVJ_t * job, graph_t *g, int s_arrows, int e_arrows);
    extern shape_desc *find_user_shape(char *);
    extern void free_line(textline_t *);
    extern void free_label(textlabel_t *);
    extern char *gd_alternate_fontlist(char *font);
    extern char *gd_textsize(textline_t * textline, char *fontname,
			     double fontsz, char **fontpath);
    extern void getdouble(graph_t * g, char *name, double *result);
    extern splines *getsplinepoints(edge_t * e);
    extern void global_def(char *,
			   Agsym_t * (*fun) (Agraph_t *, char *, char *));
    extern point image_size(graph_t * g, char *shapefile);
    extern boolean isPolygon(node_t *);
    extern char *strdup_and_subst_graph(char *str, Agraph_t * g);
    extern char *strdup_and_subst_node(char *str, Agnode_t * n);
    extern char *strdup_and_subst_edge(char *str, Agedge_t * e);
    extern char *xml_string(char *s);
    extern void makeSelfEdge(path *, edge_t **, int, int, int, int,
			     splineInfo *);
    extern textlabel_t *make_label(int, char *, double, char *, char *,
				   graph_t *);
    extern void map_begin_cluster(graph_t * g);
    extern void map_begin_edge(Agedge_t * e);
    extern void map_begin_node(Agnode_t * n);
    extern void map_edge(Agedge_t *);
    extern point map_point(point);
    extern bezier *new_spline(edge_t * e, int sz);
    extern Agraph_t *next_input_graph(void);
    extern void osize_label(textlabel_t *, int *, int *, int *, int *);
    extern char **parse_style(char *s);
    extern void place_graph_label(Agraph_t *);
    extern void place_portlabel(edge_t * e, boolean head_p);
    extern char *ps_string(char *s, int);
    extern int rank(graph_t * g, int balance, int maxiter);
    extern void routesplinesinit(void);
    extern point *routesplines(path *, int *);
    extern void routesplinesterm(void);
    extern int selfRightSpace (edge_t* e);
    extern void setup_graph(GVC_t * gvc, graph_t * g);
    extern shape_kind shapeOf(node_t *);
    extern void shape_clip(node_t * n, point curve[4]);
    extern void start_timer(void);
    extern double textwidth(textline_t * textline, char *fontname,
			    double fontsz);
    extern void translate_bb(Agraph_t *, int);
    extern void use_library(char *);
    extern void write_attributed_dot(graph_t *g, FILE *f);
    extern void write_canonical_dot(graph_t *g, FILE *f);
    extern void write_extended_dot(GVJ_t * job, graph_t *g, FILE *f);
    extern void write_plain(GVJ_t * job, graph_t * g, FILE * f);
    extern void write_plain_ext(GVJ_t * job, graph_t * g, FILE * f);

#if defined(_BLD_dot) && defined(_DLL)
#   define extern __EXPORT__
#endif

#ifndef DISABLE_CODEGENS
#ifndef HAVE_GD_FREETYPE
    extern void initDPI(graph_t *);
    extern double textheight(int nlines, double fontsz);
    extern int builtinFontHt(double fontsz);
    extern int builtinFontWd(double fontsz);
#endif
    extern codegen_info_t *first_codegen(void);
    extern codegen_info_t *next_codegen(codegen_info_t * p);
#endif

#undef extern

#ifdef __cplusplus
}
#endif
#endif
