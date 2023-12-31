<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request,
    Illuminate\Support\Facades\Gate;

use App\Models\Blog,
    App\Http\Resources\Blog as BlogResource,
    App\Http\Resources\BlogCollection,
    App\Http\Requests\StoreBlogRequest;

class BlogController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): BlogCollection
    {
        $user = $request->user();
        $blogs = Blog::where('user_id', $user->id)->get();
        return BlogCollection::make($blogs);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreBlogRequest $request)
    {
        if (!Gate::allows('create-blog')) {
            abort(403);
        }
    
        $validated = $request->validated();
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, int $id): BlogResource
    {
        $user = $request->user();
        $blog = Blog::where('user_id', $user->id)
                    ->where('id', $id)
                    ->firstOrFail();

        if (!Gate::allows('view-blog', $blog)) {
            abort(404);
        }
    
        return new BlogResource($blog);
    }

    /**
     * Display a listing of the resource requested by domain name.
     */
    public function domainName(Request $request, string $domainName): BlogResource
    {
        $user = $request->user();
        $blog = Blog::where('user_id', $user->id)
                    ->where('domain_name', $domainName)
                    ->firstOrFail();

        if (!Gate::allows('view-blog', $blog)) {
            abort(404);
        }

        return new BlogResource($blog);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, int $id): BlogResource
    {
        $blog = Blog::find($id);

        if (!Gate::allows('update-blog', $blog)) {
            abort(403);
        }

        $validated = $request->validated();
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, int $id)
    {
        $blog = Blog::find($id);

        if (!Gate::allows('delete-blog', $blog)) {
            abort(403);
        }
    }
}
