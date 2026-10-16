import { css, type Component } from "dreamland/core";

const Landing: Component<
	{
		go: (query: string) => void;
	},
	{},
	{
		query: string;
	}
> = function (cx) {
	this.query ??= "";
	cx.mount = () => {
		cx.root.querySelector("input")?.focus();
	};
	return (
		<div>
			<form
				on:submit={(e: SubmitEvent) => {
					e.preventDefault();
					if (this.query.trim()) this.go(this.query);
				}}
			>
				<h1>Welcome to Gravity</h1>
				<input
					type="text"
					value={use(this.query)}
					spellcheck="false"
					autocomplete="off"
				/>
			</form>
		</div>
	);
};

Landing.style = css`
	:scope {
		position: absolute;
		inset: 0;
		z-index: 10;
		display: flex;
		align-items: center;
		justify-content: center;
		background: black;
	}
	form {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 1.25em;
		width: min(90vw, 36em);
	}
	h1 {
		margin: 0;
		color: #fff;
		font-family: system-ui, sans-serif;
		font-weight: 600;
		font-size: 2.5em;
		text-align: center;
	}
	input {
		box-sizing: border-box;
		width: 100%;
		padding: 0.75em 1em;
		font-size: 1.05em;
		color: #e5e7eb;
		background: #0f0f0f;
		border: 1px solid #4a4a4a;
		border-radius: 999px;
		outline: none;
	}
	input:focus {
		border-color: #8f8f8f;
	}
`;

export default Landing;
